import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class FirebaseAccessToken {
  static String firebaseMessagingApi =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> generateFirebaseAccessToken() async {
    final credentialsJson = {
        "type": "service_account",
        "project_id": "phishing-c4f43",
        "private_key_id": "", // Add your firebase private key here
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCqHKbQxf42d+9x\nfYtg7SrP2cRMWCvT33HUJ6hP5S85HLfOHycObdBvCxo0p0BjJK4PQ1bDvsQe4f+h\nAyEGsZt0oZ7dvGzxpCXmybmsMpbQD8KyxMAy5/D79SvHh9mw3lG6KsEIljirrGor\nuS3n+9TqsZ6vcrpvgz8ohEDeU5u6QU9GnUT4b/Su2aeVL/ZAitd+KPMHsWu9KVV1\nW5HC9z6pFfFEQDOxb+AE/rbo5kazvGihbCjC2uHJzS811VbywuLQH+XwaVVEUhDh\newHwSKR8vGop3L6dJDpuD40LoLVrTHCIooXo3o6vLvbImJNX340o6wYMwHjpueC+\nk5vpQZi9AgMBAAECggEAB85zy03iuh4r41HnFQYdOlecfgJn1HvDDgDZ5Py3+495\nUeC1GqDoeUgRpkvslQAoarPk5eu5tU8au4lYuSVqZGJMV5GfkEE/qgUk26WgrSCk\nBy8nQM7LDMz1+tydnVO+fWQb4qh+Jkatwp7nX+d7IGART6zcqGRmABZ9oZZFpbjp\nXoJ01txUcHAdif2aKDS2Gv1rKKoDEdJIF4T7BzcHW9H5EQySXMwZGGgcTAo9iCJG\nzXoOqzJceWtk9b11ltSRdgcimN4KHByPeIvruYioHk+/bIl9kb3i+8WHCn1wYd7V\n9wvCQ9Z3dx+dW38u5AFzcprmi+LzzO7TYGIsX+uNYwKBgQDZedonTTO/ytH63AAy\nsmkzrcJej/sGhlcjhdVdCtZMn2wknlkzDLkWo9LY+y63KsaG1O5W6r7+UqEyowxU\nY8Sa2mY3NUswyMSfpZmrVV1KBwf/KEV7/Uw/5W8wBkaFNWy6bfYkd1RGFa+T9cGS\nvwGLq/g1uNMT9hebdu6Ec4kSswKBgQDIPux0bBqZ3Quif/k7SycaikJkHLQ/WYU1\n/uzFqbInokx5cNxI7AF9MkCedVp5q3Na51vjBFOV2rBb+2e7VKE4NFLC3Jnd/W6U\nQHxnohReVeGN7IfjDovyZCa9+MGT/OjgNNQwyfXvbZx00S0ySpzD0EB5LrrRG2q+\n5jhe6RuezwKBgBSVdvN/WCWQEd3XkuE5h8GPcbU3lX/hmT/QfAhpbS0lbbvtjO3L\nB33AFcXZyGsnzlCWuNRbNaamtYEwc4tNQh+SClixX6OHbSzbJLdVxhWqorQg4KrC\np8PoeGSoQ2Z6Twc6PzDmZoCXrt2nRiIYmBHbPgv/qWLbSRK66Ap7UP8HAoGAKlYj\nZ/nzJdS2QQUNjJu3CMVyg/gNo9cpcuES7jeSkw6dXI+gA0rihbW6M8Zb+p1lJjME\nGlsv0N8Lqmbc555c96UYWlqJrYWHe5CmvMJnzAocRgVcNYU90WGbT07onoE6Oyzw\nL+CDPrvN+GTBSYC85CmDeBuJI+zIBNRn1qkyTcECgYAhn7QrCQ9hm1dVJCNud2Mk\nzckT4zXFgN1ciPp2BAziVteuSSm2cuTLZ0V6LJtnPlkiPVbcSPthbhkAsvhX8j+y\nzWdLkk5MMEhp4giF2TKa3TPVCNx4DT8vJQSxwexp8SdZaKIkVPVvdp+HHqlsuKFA\njeJdImu3TeIhwH7Xh1kajg==\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-fbsvc@phishing-c4f43.iam.gserviceaccount.com",
        "client_id": "114336334223817664626",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40phishing-c4f43.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
    }
    ;

    try {
      final client = await clientViaServiceAccount(
          ServiceAccountCredentials.fromJson(credentialsJson),
          [firebaseMessagingApi]);
      final accessToken = client.credentials.accessToken.data;
      // log('OAuth 2.0 access token generated: $accessToken');
      return accessToken;
    } catch (e) {
      log('Error generating access token: $e');
      return '';
    }
  }
}