[![Circle CI](https://circleci.com/gh/eyecuelab/powur.svg?style=svg&circle-token=184c29660ce8e18b159cdf7b7a4dd36222abc97a)](https://circleci.com/gh/eyecuelab/powur)

## Working with Production DB backup

### Restore local DB from a snapshot
```
curl -o ~/Downloads/latest.dump `heroku pg:backups public-url -a powur`
rake db:drop db:create
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d powur_development ~/Downloads/latest.dump
```

### Refresh lead totals and rank ups
```
rake powur:seed:user_ranks
```

### Get latest Production backup url
```
heroku pg:backups public-url -a powur
```

### Restore Staging DB from Production backup
```
heroku pg:backups restore `heroku pg:backups public-url -a powur` DATABASE_URL -a powur-staging
```

### Prepare sensitive data for testing (ONLY for local or staging environment)
This will add test users, reset user passwords to 'solarpower' and emails to 'development+[user_id]@eyecuelab.com' etc...
```
rake powur:prepare_data_for_testing
```
