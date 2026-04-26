# Authentik deployment 

Used for user authentication and authorisation

Installation: https://docs.goauthentik.io/install-config/install/kubernetes/

```bash
helm repo add authentik https://charts.goauthentik.io
helm repo update
helm upgrade --install authentik authentik/authentik -f values.yaml
```



## How it works

1. Deploy authentik with the following:

- Email resend API key
- Ingress subdomain
- (prod) external postgres connection details (https://github.com/goauthentik/helm/tree/main/charts/authentik#advanced-values-examples)

2. Create admin user via the ingress subdomain (auth.spaces.kalavai.net)

3. Create one application per service that needs authentication:

- Client ID and secret
- Redirect URI and callback after login to point back at the service

4. Use client id and secret in the service to handle authentication. Expose callback endpoint.

5. In the service, now parse the token for permissions

6. All apps share login, so users don't have to login multiple times