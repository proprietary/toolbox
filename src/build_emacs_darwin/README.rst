Notes
------

Run ``./build_emacs_darwin.sh``

You may need to unzip all the compressed *.el files in ``/Applications/Emacs.app/Contents/Resources/lisp``::

.. code-block: bash

   cd /Applications/Emacs.app/Contents/Resources/lisp
   gunzip *.el.gz

Because we are using ``--with-native-compilation``, the dynamic libs for libgccjit need to be accessible. On the normal shell this shouldn't be a problem, but when you run GUI apps from the Finder on macOS, it doesn't inject your shell env. So you'll need to add something like this to your ``~/.emacs.d/early-init.el``:

.. code-block: lisp

   (setenv "LIBRARY_PATH"
            "/usr/lib:/usr/local/lib:/opt/homebrew/lib:/opt/homebrew/lib/gcc/current")
   (setenv "LD_LIBRARY_PATH" (getenv "LIBRARY_PATH"))
   (setenv "DYLD_LIBRARY_PATH" (getenv "LIBRARY_PATH")
   (setenv "PATH" "/usr/local/bin:/opt/homebrew/bin")

You will need to trial-and-error it depending on the locations of your dynamic libs. YMMV, etc.
