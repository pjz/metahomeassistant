IP?=hass

LOCAL_DIR=dot_homeassistant/
REMOTE_DIR=/home/homeassistant/.homeassistant/
SSH_DEST=$(IP):$(REMOTE_DIR)

DIRS=$(shell cd $(LOCAL_DIR) && find . -type d )
FILES=$(shell cd $(LOCAL_DIR) && find . -type f )



.PHONY: default
default:
	@echo get - sync remote files to here
	@echo put - sync here to remote files
	@echo restart - restart homeassistant on the homeassistant machine
	@echo update_hass - update the installed homeassistant version
	@echo update_os - update the OS on the homeassistant machine
	@echo update_all - update the OS and the installed homeassisant version
	@echo ...all respect env IP as the remote host

get:
	@cd $(LOCAL_DIR) ;\
	for f in $(FILES) ; do \
	    scp $(SSH_DEST)/$$f $$f ;\
	done

backup:
	touch dot_homeassistant/home-assistant_v2.db
	@cd $(LOCAL_DIR) ;\
	for f in $(FILES) ; do \
	    scp $(SSH_DEST)/$$f $$f ;\
	done
	tar czvf backup-`date +%Y%m%d-%H%M%S`.tgz $(addprefix $(LOCAL_DIR),$(FILES))
	rm dot_homeassistant/home-assistant_v2.db

put:
	@cd $(LOCAL_DIR) ;\
	for d in $(DIRS) ; do \
	    echo "Making dir $(REMOTE_DIR)/$$d" ;\
	    ssh $(IP) mkdir -p $(REMOTE_DIR)/$$d ;\
	done ; \
	for f in $(FILES) ; do \
	    scp $$f $(SSH_DEST)/$$f ;\
	done

DO_PLAYBOOK=ansible-playbook -i $(IP), $(ARGS) hass.yaml

restart:
	$(DO_PLAYBOOK) --tags untagged,restart_hass

update_hass:
	$(DO_PLAYBOOK) --tags untagged,update_hass

update_os:
	$(DO_PLAYBOOK) --tags untagged,update_os

update_all:
	$(DO_PLAYBOOK)

