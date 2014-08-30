
## Setting up Postgres

Follow the instuctions here:

https://devcenter.heroku.com/articles/heroku-postgresql#local-setup

## Resetting the DB

```bash
rake db:drop db:create db:migrate
```

## Seed the DB with admin users

```bash
rake db:seed
```

## Seed the DB with the default Products, Bonus Plan, Ranks and Qualifications

The database must not have any Quotes or Orders in order for this to work.

```bash
rake sunstand:seed:bonus_plan
```

Two products are created. One Solar Item product as well as the Consultant Certification product.

## Simulate User Genealogy

```bash
rake sunstand:simulate:users
```

There are options that can be used on this command in the form 

```bash
rake sunstand:simulate:users[1000,20,3]
```

The first argument is the approximate total # of users. The second is the max # of users in one users particular downline. The third argument is the max of levels to generate for the root users' downline. Note that there must be no spaces in the list of arguments between the brackets. The arguments in the example are the defaults.

## Simulate Orders

```bash
rake sunstand:simulate:orders
```

Arguments can be used for this command as well

```bash
rake sunstand:simulate:orders[20,4]
```

The first argument is the average # of orders per user. A random amount is selected between 0 and twice the #. Orders are generated for approximately 85% of the users for the Solar Item product. One order is created for approximately 75% of the users for the Consultant Certification product. The second argument is how many months back in which to generate orders. A random date is selected between the first of that month and now. The amounts in the example are the defaults. 

