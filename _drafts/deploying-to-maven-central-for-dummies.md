*NOTE: I probably won't ever finish / publish this blog post. At this point, it's been too long since I went through this process, and the process may have changed significantly since then. I think the boot pom generation part may have improved too. At the moment, it's looking like this would-be blog post shall forever live in limbo as a draft. I'll at least refer to it if/when I ever need to deploy another huge package to Maven Central.*

# Why I had to do it

I wanted to package a 141 MB soundfont as a Maven repo for use as a dependency with midi.soundfont, a Clojure library for loading MIDI soundfonts into the JVM. My go-to packaging method for Clojure dependencies is Clojars, however they have a 20 MB limit on package sizes.

Maven Central doesn't have such limits, but what it does have is an insanely complicated deploy process. This is to document what I did for future reference, and in the hopes that it will help someone.

# The Process

1. **Create a JIRA account, fill out the form to submit a ticket.** This is just a one-time step to set up your repository groupId, to my understanding. I initially wanted midi.soundfont (to namespace soundfonts), however as we discussed on the JIRA ticket, your groupId must follow the convention of the reverse domain name, e.g. com.google.
My next proposal was org.daveyarwood (it's simple), but I do not own that domain name (and I don't really feel like purchasing a domain I won't use), so that was out. I ended up settling on org.bitbucket.daveyarwood, since this project is hosted on my Bitbucket account. (note: you have to wait for OSSRH team to set up your groupId before you can do steps 6-8)
2. **Create the pom & jar (`boot pom jar`).** Manually adjust pom.xml -- you should just have to add the `<developers>` section, assuming the other stuff was included in the task options for the `pom` task.
3. **Set up a PGP key, if you don't already have one.** Upload your PGP key so OSSRH can authenticate your jar bundle.
4. **Sign everything (jar, pom.xml, -sources.jar, -javadoc.jar).** Make fake -sources.jar and -javadoc.jar if needed.
5. **Make a jar bundle.** (`jar cvf bundle.jar ...`) Include all 4 files, as well as their .asc versions.
6. **Sign into the OSSRH web UI and upload bundle.jar.**
7. **Ensure (via the web UI) that there were no validation errors. Adjust as needed.**
  * Problems I ran into:
    * I hadn't uploaded my PGP key, so authentication failed.
    * My pom.xml was missing a `<developers>` section.
    * I was missing -sources.jar and -javadoc.jar (I don't remember if this actually gave me an error, but I did it anyway as I was reading the Maven requirements)
  * You should get an email if all the validation steps pass.
8. **Click the 'Release' button. Comment on the JIRA comment thread noting that you have done so (if this is the first time you're releasing to this repo; after that, it will be automatic).**

# The Future

We already have bootlaces, which I have used in the past to deploy projects to clojars with minimal effort.

Boot also has a built-in task called `push`, which is very configurable and you can actually (almost) use it to deploy stuff to Maven Central.

One small issue: the `pom` task doesn't include all of the things that Maven requires -- the `<developers>` section at least.

## Optimized deploy process

(once `pom` task is improved to make a Maven-compliant pom.xml)

1. **Create a JIRA account, fill out the form to submit a ticket.** (Maybe you've already done this.)
2. **Include OSSRH repository in build.boot.** Include `:url`, `:username` and `:password` keys. Don't be stupid, read the username and password from environment variables. (show actual build.boot)
3. **Deploy to staging repository.** This actually worked for me (the pom.xml just wasn't fully Maven-compliant): `boot pom jar push -K ~/.gnupg/secring.gpg -r ossrh`
4. **Log into OSSRH web UI, confirm validation passed and everything is there, click 'Release'.**

We are wondering if we can even automate more of this -- the validation part is a Java library, possibly open source...?, could see if that can be incorporated into a boot task.

Boot: making incredibly complicated things ridiculously easy.
