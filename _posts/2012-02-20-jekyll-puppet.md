---
layout: post
title: Introducing Jekyll-Puppet
synopsis: On using configuration management tool Puppet to automate Jekyll installations.
topics:
  - jekyll
  - puppet
  - automation
---
[Jekyll](http://jekyllrb.com/) is lightweight CMS platform (static content generator, technically speaking) that is very well in-tune with how devs think and work. I was experimenting with it one night and was really quite taken by it. I've since rolled this site into it.


### Getting Jekyll Online

Installing and Configuring Jekyll itself isn't bad, just a matter of pulling in a couple of gems and using WEBrick for testing.  The extra leg work comes from setting up a preferred environment online. i.e.- webserver, deploy user, configuring bare git repo with post-receive hook, etc..  Nothing crazy, just a lot of steps when taken together.  So I decided to use some [Puppet](http://docs.puppetlabs.com/) magic to make setting everything up in this way a snap:

* Automatically install &amp; configure Jekyll plus any dependencies/gems
* Pygments for syntax highlighting
* Nginx webserver
* Deploy user that you can git-push to (a.k.a post-receive hook from: [Jekyll Deployment](https://github.com/mojombo/jekyll/wiki/Deployment))
* Bare git repository under 'deploy' user that automatically publishes when pushed
* Install faster [LSI](http://en.wikipedia.org/wiki/Latent_semantic_indexing) dependencies for 'related posts' computation


### Automated Jekyll Setup using Puppet

As a bonus everything is _Puppetized_, so it's easy to tweak/swap-out any config bits to your liking. Setup involves just a few simple steps:

1. Log into server and and install dependencies:
   `sudo aptitude update && sudo aptitude install puppet git rubygems`
2. `git clone git://github.com/sjmio/Jekyll-Puppet.git` (can be deleted once finished if you want)
3. cd into Jekyll-Puppet directory and run puppet agent to configure everything:
   `sudo puppet apply --modulepath=modules setup.pp`
4. Append your ssh public-key (id_rsa.pub) to the 'deploy' users ~/.ssh/authorized_keys. Note that `ssh-copy-id deploy@myserver.com` won't work since the deploy user is setup without a password (Feel free to change).

The following was tested on Ubuntu 11.10 (Oneiric Ocelot):
{% highlight bash %}
sean@remote:~/$ sudo aptitude update && sudo aptitude install puppet git rubygems
...
sean@remote:~/$ git clone git://github.com/sjmio/Jekyll-Puppet.git && cd Jekyll-Puppet
sean@remote:~/$ sudo puppet apply --modulepath=modules setup.pp
...
{% endhighlight %}

Once your public ssh-key from your local dev machine is copied to the 'deploy' user, this is what you'd do to clone [http://sjm.io/](http://sjm.io/) onto your new server.

{% highlight bash %}
sean@local:~/$ git clone git@github.com:sjmio/sjm.io.git && cd sjm.io
sean@local:~/$ git remote add deploy deploy@myserver.com:~/Jekyll-Puppet.git
sean@local:~/$ git push deploy master
{% endhighlight %}

### Conclusion

At this point you should be able to hit your server in any web browser and see this site coming through.  Beyond that this is my regular workflow:

1. Make changes locally and use jekyll --auto --server
2. When things look good commit and push to remote(s)
3. Get out of chair and _Melbourne Shuffle_ (youtube is your friend)

