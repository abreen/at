`@` - chat with other users
===========================

`@` is a tiny Bash script designed for asynchronous chat among users
on a single UNIX timesharing system. `@` is similar to `write`,
but allows more than one user to chat with each other. `@` is also
asynchronous: like `mail`, it does not have to run in the background
and will not notify you of new activity in your chat rooms until you
invoke `@` again.

`@` is quick and will not make any noise if there is no activity in
your chat rooms since the last time `@` was run. Therefore it is
ideal to be added to your shell prompt as a hook, but this is entirely
up to you.

The design of `@` is simple: each chat room is simply a file, and users
append to the file to send a message to the room. Thus every installation
of `@` has to be directed to the same directory when looking for
chat room files. By default, `@` creates chat room files in `/tmp/rooms`.

`@` supports colored output, but this can be switched off by changing
a constant in the source code.


Usage
-----

    [abreen@tuvok] # no arguments: checks for new activity
    [abreen@tuvok] @
    @: not joined to any chat rooms
    [abreen@tuvok] # use --join flag to join a chat room
    [abreen@tuvok] @ --join general
    @: no such chat room
    [abreen@tuvok] # there is no chat room file 'general' on the system
    [abreen@tuvok] # we can start it by sending a message to it
    [abreen@tuvok] @ general hello world
    @: creating room 'general'
    @: auto-joining 'general'
    [abreen@tuvok] # see a recent history of messages by supplying room name
    [abreen@tuvok] @ general
    @general (recent history)
     7:14:24 abreen: hello world
    [abreen@tuvok] # see joined rooms by using --rooms
    [abreen@tuvok] @ --rooms
    general
    [abreen@tuvok] # leave a room by using --leave
    [abreen@tuvok] @ --leave general
    @: left room 'general'
    [abreen@tuvok] # leaving a room will not destroy the chat room file
    [abreen@tuvok] # and you can join again later
    [abreen@tuvok] # final note: if you are joined to multiple chat rooms,
    [abreen@tuvok] # you will see recent activity for each room when you
    [abreen@tuvok] # invoke `@` with no arguments
