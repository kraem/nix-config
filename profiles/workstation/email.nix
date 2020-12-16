{ config, pkgs, ... }:
let
  fullname = (import ../../secrets.nix).fullname;
  email = (import ../../secrets.nix).email;
  dotfiles = ((import ../../nix).dotfiles);

  home = config.users.users.kraem.home;
  group = config.users.users.kraem.group;
  permissions = "0711";

  # NB if mbsync complains slave xxx cannot be opened:
  # NB remove the mbsync cache dir: ~/.mbsync
  # NB SyncState solves this by putting state files in the
  # NB the corresponding slave maildirs instead of ~/.mbsync
  channelExtraConfig = {
    Create = "Slave";
    SyncState = "*";
  };
in
{


  systemd.tmpfiles.rules = [
    "d ${home}/mail ${permissions} kraem ${group} -"
    "d ${home}/mail/kth ${permissions} kraem ${group} -"
    "d ${home}/mail/gmail ${permissions} kraem ${group} -"
    "d ${home}/mail/mailbox ${permissions} kraem ${group} -"
  ];

  environment.systemPackages = with pkgs; [
    w3m
  ];

  home-manager.users.kraem = { ... }: {

    programs.mbsync = {
      enable = true;
    };
    programs.msmtp.enable = true;
    programs.neomutt = {
      enable = true;
      sort = "reverse-date-received";
      vimKeys = true;
      sidebar.enable = false;
      extraConfig = ''
        set mailcap_path = ${(dotfiles + "/mutt/mailcap")}
        auto_view text/html

        set sleep_time = 0

        # rebind d to delet instead of dd from vimkeys
        bind pager,index                d   noop
        bind pager,index                d  delete-message

        macro index 'c' '<change-folder>?<change-dir><home>^K=<enter>'

        # sidebar and macro broken
        #macro index,pager <f1> "<enter-command> source ${config.users.users.kraem.home}/neomutt/gmail<enter> <change-folder> ${config.users.users.kraem.home}/mail/gmail/inbox <enter>"
        #macro index,pager <f2> "<enter-command> source ${config.users.users.kraem.home}/neomutt/kth<enter> <change-folder>${config.users.users.kraem.home}/mail/kth/inbox<enter>"
        #macro index,pager <f3> "<enter-command> source ${config.users.users.kraem.home}/neomutt/mailbox<enter> <change-folder>${config.users.users.kraem.home}/mail/mailbox/inbox<enter>"
        #bind index,pager \Cb sidebar-toggle-visible
        #bind index,pager \Ck sidebar-prev
        #bind index,pager \Cj sidebar-next
        #bind index,pager \Co sidebar-open

        # The correct charset and mime type may be set in the email header but not in the
        # HTML <meta> tag itself, the email header charset needs to be propagated to the graphical browser.
        # https://wiki.archlinux.org/index.php/Mutt#Viewing_HTML
        macro attach 'V' "<pipe-entry>iconv -c --to-code=UTF8 > ~/.cache/neomutt/mail.html<enter><shell-escape>$BROWSER ~/.cache/neomutt/mail.html &>/dev/null<enter>"

        ###############################################################################

        # general ------------ foreground ---- background -----------------------------
        color error		color231	color212
        color indicator		color231	color241
        color markers		color210	default
        color message		default		default
        color normal		default		default
        color prompt		default	        default
        color search		color84		default
        color status 		color141	color236
        color tilde		color231	default
        color tree		color141	default

        # message index ------ foreground ---- background -----------------------------
        color index		color210	default 	~D # deleted messages
        color index		color84		default 	~F # flagged messages
        color index		color117	default 	~N # new messages
        color index		color212	default 	~Q # messages which have been replied to
        color index		color215	default 	~T # tagged messages
        color index		color141	default		~v # messages part of a collapsed thread

        # message headers ---- foreground ---- background -----------------------------
        color hdrdefault	color117	default
        color header		color231	default		^Subject:.*

        # message body ------- foreground ---- background -----------------------------
        color attachment	color228	default
        color body		color231	default		[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+               # email addresses
        color body		color228	default		(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+        # URLs
        color body		color231	default		(^|[[:space:]])\\*[^[:space:]]+\\*([[:space:]]|$) # *bold* text
        color body		color231	default		(^|[[:space:]])_[^[:space:]]+_([[:space:]]|$)     # _underlined_ text
        color body		color231	default		(^|[[:space:]])/[^[:space:]]+/([[:space:]]|$)     # /italic/ text
        color quoted		color61		default
        color quoted1		color117	default
        color quoted2		color84		default
        color quoted3		color215	default
        color quoted4		color212	default
        color signature		color212	default
      '';
    };
    accounts.email = {
      maildirBasePath = "mail";
      accounts.gmail = {
        address = "${email.gmailFull}";
        maildir = { path = "gmail"; };
        folders = { inbox = "inbox"; };
        #gpg = {
        #  key = "";
        #  signByDefault = true;
        #};
        imap.host = "imap.gmail.com";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          patterns = [ "*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail" ];
          groups = {
            "google" = {
              channels = {
                "inbox" = {
                  masterPattern = "INBOX";
                  slavePattern = "inbox";
                  extraConfig = channelExtraConfig;
                };
                "sent" = {
                  masterPattern = "[Gmail]/Sent Mail";
                  slavePattern = "sent";
                  extraConfig = channelExtraConfig;
                };
                "archive" = {
                  masterPattern = "[Gmail]/All Mail";
                  slavePattern = "archive";
                  extraConfig = channelExtraConfig;
                };
                "drafts" = {
                  masterPattern = "[Gmail]/Drafts";
                  slavePattern = "drafts";
                  extraConfig = channelExtraConfig;
                };
                "trash" = {
                  masterPattern = "[Gmail]/Trash";
                  slavePattern = "trash";
                  extraConfig = channelExtraConfig;
                };
                "spam" = {
                  masterPattern = "[Gmail]/Spam";
                  slavePattern = "spam";
                  extraConfig = channelExtraConfig;
                };
              };
            };
          };
          extraConfig = {
            channel = {
              Sync = "All";
            };
            account = {
              Timeout = 120;
            };
          };
        };
        neomutt = {
          enable = true;
          extraConfig = ''
            set folder              = "~/mail/gmail"
            set spoolfile           = "~/mail/gmail/inbox"
            set record              = "~/mail/gmail/sent"
            set mbox                = "~/mail/gmail/archive"
            set postponed           = "~/mail/gmail/drafts"
            set trash               = "~/mail/gmail/trash"
            unmailboxes *
            mailboxes =inbox =sent =archive =drafts =trash =spam
            macro index R "<shell-escape>mbsync google<enter>"
          '';
        };
        primary = true;
        realName = "${fullname}";
        passwordCommand = "gopass show --password website/google.com/1personal-app-password";
        msmtp.enable = true;
        smtp = {
          host = "smtp.gmail.com";
        };
        userName = "${email.gmailFull}";
      };
      accounts.mailbox = {
        address = "${email.mailboxFrom}";
        maildir = { path = "mailbox"; };
        folders = { inbox = "inbox"; };
        #gpg = {
        #  key = "";
        #  signByDefault = true;
        #};
        imap.host = "imap.mailbox.org";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          #patterns = ["*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail"];
          groups = {
            "mailbox" = {
              channels = {
                "inbox" = {
                  masterPattern = "INBOX";
                  slavePattern = "inbox";
                  extraConfig = channelExtraConfig;
                };
                "sent" = {
                  masterPattern = "Sent";
                  slavePattern = "sent";
                  extraConfig = channelExtraConfig;
                };
                "archive" = {
                  masterPattern = "Archive";
                  slavePattern = "archive";
                  extraConfig = channelExtraConfig;
                };
                "drafts" = {
                  masterPattern = "Drafts";
                  slavePattern = "drafts";
                  extraConfig = channelExtraConfig;
                };
                "trash" = {
                  masterPattern = "Trash";
                  slavePattern = "trash";
                  extraConfig = channelExtraConfig;
                };
                "spam" = {
                  masterPattern = "Junk";
                  slavePattern = "spam";
                  extraConfig = channelExtraConfig;
                };
              };
            };
          };
          extraConfig = {
            channel = {
              Sync = "All";
            };
            account = {
              Timeout = 120;
              #PipelineDepth = 1;
            };
          };
        };
        neomutt = {
          enable = true;
          extraConfig = ''
            set folder              = "~/mail/mailbox"
            set spoolfile           = "~/mail/mailbox/inbox"
            set record              = "~/mail/mailbox/sent"
            set mbox                = "~/mail/mailbox/archive"
            set postponed           = "~/mail/mailbox/drafts"
            set trash               = "~/mail/mailbox/trash"
            unmailboxes *
            mailboxes =inbox =sent =archive =drafts =trash
            macro index R "<shell-escape>mbsync mailbox<enter>"
          '';
        };
        primary = false;
        realName = "${fullname}";
        passwordCommand = "gopass show --password website/mailbox.org/personal";
        msmtp.enable = true;
        smtp = {
          host = "smtp.mailbox.org";
        };
        userName = "${email.mailboxUser}";
      };
      accounts.kth = {
        address = "${email.kthFull}";
        maildir = { path = "kth"; };
        folders = { inbox = "inbox"; };
        #gpg = {
        #  key = "";
        #  signByDefault = true;
        #};
        imap.host = "webmail.kth.se";
        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "both";
          patterns = [ "*" ];
          groups = {
            "kth" = {
              channels = {
                "inbox" = {
                  masterPattern = "INBOX";
                  slavePattern = "inbox";
                  extraConfig = channelExtraConfig;
                };
                "sent" = {
                  masterPattern = "Sent Items";
                  slavePattern = "sent";
                  extraConfig = channelExtraConfig;
                };
                "archive" = {
                  masterPattern = "Archive";
                  slavePattern = "archive";
                  extraConfig = channelExtraConfig;
                };
                "drafts" = {
                  masterPattern = "Drafts";
                  slavePattern = "drafts";
                  extraConfig = channelExtraConfig;
                };
                "trash" = {
                  masterPattern = "Deleted Items";
                  slavePattern = "trash";
                  extraConfig = channelExtraConfig;
                };
                "spam" = {
                  masterPattern = "Junk Email";
                  slavePattern = "spam";
                  extraConfig = channelExtraConfig;
                };
              };
            };
          };
          extraConfig = {
            channel = {
              Sync = "All";
            };
            account = {
              Timeout = 120;
              # quote mbsyncrc:
              # "to spare flaky servers like M$ Exchange"
              PipelineDepth = 1;
            };
          };
        };
        neomutt = {
          enable = true;
          extraConfig = ''
            set folder              = "~/mail/kth"
            set spoolfile           = "~/mail/kth/inbox"
            set record              = "~/mail/kth/sent"
            set mbox                = "~/mail/kth/archive"
            set postponed           = "~/mail/kth/drafts"
            set trash               = "~/mail/kth/trash"
            unmailboxes *
            mailboxes =inbox =sent =archive =drafts =trash
            macro index R "<shell-escape>mbsync kth<enter>"
          '';
        };
        primary = false;
        realName = "${fullname}";
        passwordCommand = "gopass show --password website/kth.se/personal";
        msmtp = {
          enable = true;
        };
        smtp = {
          host = "smtp.kth.se";
          port = 587;
          tls = {
            useStartTls = true;
          };
        };
        userName = "${email.kthUser}";
      };
    };
  };
}
