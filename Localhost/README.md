# HTTPS and (local) Development Servers

During development it is ofter useful have apps target a backend development server running locally (localhost).
And to correctly mimic a production environment, the communication with that server should also user HTTPS.

Development servers, running locally or not, usually use a TLS certificate signed by a custom CA (Certificate Authority). The CA's root certificate must then be manually trusted by simulators and test devices.

> Note: By default (on newer iOS versions), calling insecure HTTP endpoints on localhost from Simulator is allowed. Ref: [NSAllowsLocalNetworking](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity/nsallowslocalnetworking).

Resources:

- [App Transport Security (ATS)](https://developer.apple.com/documentation/bundleresources/information-property-list/nsapptransportsecurity)
- [Installing a CA’s Root Certificate on Your Test Device](https://developer.apple.com/library/archive/qa/qa1948/_index.html#//apple_ref/doc/uid/DTS40017603-CH1-SECINSTALLING)
- [Creating Certificates for TLS Testing](https://developer.apple.com/library/archive/technotes/tn2326/_index.html#//apple_ref/doc/uid/DTS40014136)

Installing, and trusting, a (self-signed) root CA (Certificate Authority) Certificate via the command line:

```shell
xcrun simctl keychain "<device>" add-root-cert "<path-to-ca-cert>"

# Example:
xcrun simctl keychain "iPhone 17 Pro Max" add-root-cert ~/.ssh/thomsmed.ca.crt
```
