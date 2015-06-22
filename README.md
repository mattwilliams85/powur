[![Circle CI](https://circleci.com/gh/eyecuelab/powur.svg?style=svg&circle-token=184c29660ce8e18b159cdf7b7a4dd36222abc97a)](https://circleci.com/gh/eyecuelab/powur)


## Seeding your DB (not to be done in production)

```
rake powur:seed:products
rake powur:seed:zip_codes
rake powur:seed:library
rake powur:seed:advocates
rake powur:seed:leads
rake powur:seed:submitted_leads
rake powur:import:lead_updates DATA_API_ENV=production
rake powur:seed:plan
```


## Working with Production DB backup

### Restore local DB from a snapshot

```
curl -o ~/Downloads/latest.dump `heroku pg:backups public-url -a powur`
rake db:drop db:create
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d powur_development ~/Downloads/latest.dump
```

### Prepare sensitive data for testing (ONLY for local or staging environment)

This will add test users, reset user passwords to 'solarpower' and emails to 'development+[user_id]@eyecuelab.com' etc...

```
rake powur:prepare_data_for_testing
```

### Get latest Production backup url

```
heroku pg:backups public-url -a powur
```

### Restore Staging DB from Production backup

```
heroku pg:backups restore [backup url] DATABASE_URL -a powur-staging
```
