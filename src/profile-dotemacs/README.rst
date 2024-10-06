Profiling init.el
-----------------

Edit this line to point to your init file::

  (defvar profile-dotemacs-file "~/.emacs" "File to be profiled.")

Usage::

  emacs -Q -l PATH/profile-dotemacs.el -f profile-dotemacs
