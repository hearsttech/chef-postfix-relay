### Unreleased

## 0.4.3 (2019-01-23)
* Remove postfix install details, which are already handled by the included postfix::default inclusion

## 0.4.2 (2018-09-06)
* Bump development-time gem versions
* Fix provisioning sasl_auth with the new attribute structure : attributes have been renamed as 
  well as moved about. No longer throw if old-style attributes are set - these may be set in a 
  persisted node object from a previous run : we just need to delete them.

## 0.4.1 (2018-08-29)
* Require postfix > 5.3 and implement fix for the breaking change to their sasl_auth config attributes
  in that version : throws exception if still defined and non-empty in your project (see 
  chef-cookbooks/postfix#134). Fix spotted by @PeterGrace.

## 0.4.0 (2017-08-10)
* Ignore build-time files from the vendored cookbook
* Update build dependencies and build against Chef 12 and Chef 13 (drops support for < 12.18.31)

### 0.3.0

* Update to postfix cookbook v5.0
* Require Chef 12+

### 0.2.0

* Upgrade to align with postfix cookbook v3.6.0, in particular update all dynamic attributes to be normal precedence
  so that they win over the default attributes provided by [postfix:_common]

### 0.1.0

* Initial version, never tagged
