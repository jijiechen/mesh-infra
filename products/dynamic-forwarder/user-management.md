
# Feature toogle

If the file `data/users.txt` starts with `BYPASS_AUTH_FOR_INTERNAL_USERS`, the authorization feature will be disabled for internal users, which means all internal traffic will be forwarded defaultly.

Internal addresses start with these:

* 10.
* 127.
* 172.
* 192.168.

# User management

Please put user credentials in the `data/users.txt`, each line is for one user, in this format: `base64(username:password)`

For example, execute the following command to generate a user credential with username `jim` and password `verySecretP@ssword`:

```sh
echo -n "jim:verySecretP@ssword" | base64
# outputs: amltOnZlcnlTZWNyZXRQQHNzd29yZA==
```

# Test users

* ok:test1
* ok:test2

```
b2s6dGVzdDE=
b2s6dGVzdDI=
```