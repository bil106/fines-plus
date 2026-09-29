# CarPapers web pages

Static pages Google Play requires for CarPapers (all its flavors:
`carpapers`, `carpapersmx`, `carpapersar`), served by Firebase Hosting in the
CarPapers project `carpapers-bde41`:

- `public/delete-account/index.html` →
  https://carpapers-bde41.web.app/delete-account (Play Console → App content →
  Data safety → account deletion URL).
- `public/privacy/index.html` → https://carpapers-bde41.web.app/privacy
  (Play Console → App content → Privacy policy; also `privacyPolicyUrl` in
  `assets/config/carpapers*.json`).
- `public/terms/index.html` → https://carpapers-bde41.web.app/terms
  (`termsUrl` in `assets/config/carpapers*.json`, linked from the
  subscription screen).
- `public/style.css`, `public/logo.png` - shared by the pages.

Kept apart from the repo-root `public/` (Fines+'s hosting, incl. its
`.well-known/assetlinks.json`) and the root `firebase.json`, so a deploy here
can never touch the Fines+ site. Deploy from the repo root:

```
firebase deploy --only hosting --config hosting/carpapers/firebase.json --project carpapers-bde41
```

The support email appears in every page's text and `mailto:` links (EN and ES);
keep it in sync with `supportEmail` in `assets/config/carpapers*.json`.
