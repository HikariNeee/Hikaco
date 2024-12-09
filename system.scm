(use-modules (gnu)
	     (gnu services networking)
	     (gnu services ssh)
	     (gnu services desktop)
	     (gnu services dbus)
	     (gnu services shepherd)
	     (gnu packages ssh)
	     (gnu packages zig-xyz)
	     (gnu packages terminals)
	     (gnu packages shells)
	     (gnu packages dns)
	     (gnu packages fontutils)
	     (gnu packages librewolf)
	     (gnu packages admin)
	     (gnu packages mail)
	     (gnu packages linux)
	     (gnu packages wm)
             (gnu packages gnome-xyz)
             (gnu packages kde-frameworks)
	     (gnu packages rust-apps)
	     (gnu packages xdisorg)
	     (gnu packages image)
	     (gnu packages version-control)
	     (gnu packages emacs)
	     (gnu packages compression)
	     (nongnu packages linux)
	     (nongnu system linux-initrd))

(define nonguix-pub-key
  (plain-file "nonguix-pub-key.pub"
    "(public-key 
       (ecc 
         (curve Ed25519)
           (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))

(define bordeaux-inria-key 
  (plain-file "bordeaux-inria-key.pub"
    "(public-key
       (ecc
        (curve Ed25519)
         (q #89FBA276A976A8DE2A69774771A92C8C879E0F24614AAAAE23119608707B3F06#)))"))

(operating-system
  (kernel linux)
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (host-name "Hikaco")
  (timezone "Asia/Kolkata")
  (locale "en_GB.utf8")

  (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (timeout 3)
                (terminal-outputs '(console))
                (targets '("/dev/sda"))))

  (initrd-modules (cons* "i915" %base-initrd-modules))
  (kernel-arguments
   (list
    "mitigations=off"
    "loglevel=3"
    "tsc=reliable"
    "page_alloc.shuffle=1"))
  
  (file-systems (append (list (file-system
                               (device "/dev/sda4")
                               (mount-point "/")
                               (type "ext4"))                               
                              (file-system
                               (mount-point "/tmp")
                               (device "none")
                               (type "tmpfs")
                               (check? #f))) 

                      %base-file-systems))

  (swap-devices 
    (list (swap-space (target "/dev/sda3"))))

  (users (cons (user-account
                (name "hikari")
                (group "users")
		(supplementary-groups '("wheel" "audio" "video")))
               %base-user-accounts))

  (packages (cons* 
	      river foot fnott i3status-rust wl-clipboard grim slurp fontconfig fuzzel
               %base-packages))

  ;; Add services to the baseline: a DHCP client and
  ;; an SSH server.
  (services (append (list (service dhcp-client-service-type)
                          (service nftables-service-type)
                          (service dbus-root-service-type)
                          (service elogind-service-type)
                          (service polkit-service-type)
                          (service openntpd-service-type 
                            (openntpd-configuration
                              (servers '("0.arch.pool.ntp.org"))))

                          (service openssh-service-type
                           (openssh-configuration
                            (openssh openssh-sans-x)
                            (port-number 2222))))
		    
		    (modify-services %base-services
                      (guix-service-type config => (guix-configuration
                        (inherit config)
	                (substitute-urls
			  (append 
                            (list 
                              "https://substitutes.nonguix.org"
                              "https://guix.bordeaux.inria.fr")
	                    %default-substitute-urls))
		          (authorized-keys
			    (append 
                              (list 
                               nonguix-pub-key
                               bordeaux-inria-key)
			      %default-authorized-guix-keys))))))))

	
