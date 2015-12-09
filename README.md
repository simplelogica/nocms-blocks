# NoCMS Blocks

## What's this?

This is a Rails engine with a basic functionality of customizable blocks of
content attachable to objects. It's not attached to any particular CMS so you
can use it freely within your Rails application without too much dependencies.

## How do I use this?

1. [Install the gem into your app](./doc/install.md)
2. [Configure some layouts for your blocks](./doc/layouts.md)
3. [Define templates and zones where your blocks fit](./doc/templates.md)
4. [Add blocks to your model](./doc/models.md)
5. [Render the blocks in your templates](./doc/render.md)
6. [Be careful with the cache](./doc/cache.md)
7. [And use a god admin interface :)](./doc/admin.md)

## How do I make some PR?

1. [Behave yourself](./CODE_OF_CONDUCT.md)
2. Clone the repo
3. Commit your changes in a new branch.
4. Test your changes in all the [Appraisals](https://github.com/thoughtbot/appraisal). Notice that using appraisals is mandatory as no database gem is listed in the default gemfile.

- Test that your changes don't break any right behaviour from the tests.
- Test that any new feature is properly tested.
- If some feature is only appliable in some Rails version or database you should make sure that any other appraisal is still working. You can limit your new feature by using `Rails.version` and `NoCms::Blocks.installed_db_gem`.

Finally, ask for a pull request and we will be very grateful.
