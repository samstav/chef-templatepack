Fastfood Stencil Guidelines
===========================

1) First and foremost a stencil should not try to handle every possible
   condition that may exist.  That is why stencils are a subset of
   stencil_sets which allow for different stencils to handle different
   possiblities.  So a rails stencil_set should not have one stencil that
   handles both Nginx and Apache in the same stencil.  They should be
   broken out into multiple stencils.

2) In almost all cases Chef should be responsible for logic concerning
   distro and OS versions.  This makes the recipes slightly more verbose
   in some cases but it leaves it up to Chef (which was designed for this).

3) Ubuntu 12.04 and 14.04 as well as Centos 6.x and Centos 7.x are the primary
   targets for our customer base so a stencil should ideally support those
   Linux distros at the minimum.

4) Logic in the stencils should be kept to a minimum and should be reserved
   for adding extra functionality to a recipe.  For instance if you have
   a postgresql recipe and would like to add the option for monitoring or
   backups you would guard that functionality with a simple if statment in
   the recipe template.  Stencils can also be used as a way to handle logic,
   so rather than having an if else statement for the above backup scenario
   you could simple create a new stencil inside that stencil set and add
   a backup recipe to the list of files.

5) Any recipe that is meant to be called by recipes and not directly included
   in the run list should be prefixed with an _ similarly to how Python makes
   "private" methods.  So for instance if I have a recipe that includes another
   recipe maybe to keep common functionality else where; It should look like
   the following:

   ```ruby
   myrecipe.rb

   include_recipe '{{cookbook['name']}}_common'
   ```

[Examples](https://github.com/jarosser06/chef-templatepack)
