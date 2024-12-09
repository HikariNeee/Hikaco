(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix packages)
             (guix gexp)
             (guix download)
             (guix build-system font)
             (guix licenses)
             (gnu home services)
             (gnu home services shells)
             (gnu home services sound)
             (gnu home services desktop)
             (gnu home services shepherd))

(define-public iosevka-ss17
  (package 
    (name "Iosevka-ss17")
    (version "32.2.1")
    (source
      (origin
        (method url-fetch/zipbomb)
        (uri "https://github.com/be5invis/Iosevka/releases/download/v32.2.1/PkgTTF-IosevkaSS17-32.2.1.zip")
        (sha256
          (base32 "1z3k6310a3bsx6g7d0wfmnzrypy3lkf37gsy88b4ndx7flfrn5yw"))))
    (build-system font-build-system)
    (synopsis "iosevka recursive version")
    (description "iosevka recursive version")
    (home-page "https://github.com/be5invis/Iosevka")
    (license silofl1.1)))

(define %base-packages
  (map specification->package+output
       (list "librewolf"
	     "fish"
             "emacs-pgtk"
             "fish-foreign-env"
	     "hydroxide"
	     "bibata-cursor-theme"
	     "hicolor-icon-theme"
             "adwaita-icon-theme"
	     "htop"
	     "unzip"
	     "git:send-email"
	     "pipewire"
	     "wireplumber"
             "pavucontrol"
             "font-google-noto"
             "font-google-noto-sans-cjk"
             "font-google-noto-emoji"
             "font-google-material-design-icons"
             "font-recursive"
             "font-google-roboto"
             "glib")))

(home-environment
  (packages (cons* iosevka-ss17 %base-packages))
  (services
   (list (service home-dbus-service-type)
         (service home-fish-service-type)
         (simple-service 'emacs-daemon home-shepherd-service-type
           (list
             (shepherd-service
               (provision '(emacs-daemon))
               (start 
                 #~(make-forkexec-constructor 
                  (list #$(file-append (specification->package "emacs-pgtk") "/bin/emacs") "--fg-daemon")))
               (stop #~(make-kill-destructor))
               (respawn? #t))))

         (service home-files-service-type
             `((".bashrc",                    (local-file "./files/bashrc"))))

         (service home-xdg-configuration-files-service-type
             `(("foot/foot.ini",              (local-file "./files/foot.ini"))
               ("i3status-rust/config.toml",  (local-file "./files/i3status-rust.toml"))
               ("i3bar-river/config.toml",    (local-file "./files/i3bar-river.toml"))
               ("gtk-3.0/gtk.css",            (local-file "./files/gtk.css"))
               ("gtk-3.0/settings.ini",       (local-file "./files/gtk-settings.ini"))
               ("emacs/init.el",              (local-file "./files/emacs.el"))
               ("fuzzel/fuzzel.ini",          (local-file "./files/fuzzel.ini"))))
	 (service home-pipewire-service-type))))
