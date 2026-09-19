# phpBB2-again

This is an updated version of phpBB 2.0.23 with:

* PHP 8 compatibility
* SQLite database driver
* Migrated mysql driver to mysqli
* Removed mssql, db2, msaccess, postgres drivers
* Security hardening
  * use built in PHP password\_hash (bcrypt) instead of md5
  * actually check the existing hidden fields to prevent CSRF
  * set cookies to HttpOnly SameSite=Lax
  * rate limiting on password reset
  * IPv6 IP support in the ban list
  * removed "upload an avatar from an external url"
* "Disable all emails" admin setting
* Removed version/upgrade check
