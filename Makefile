TARGETS = openjdk8 wildfly wildfly-oracle
REPO    = caspard

.PHONY: default
default: wildfly.build

.PHONY: build
build: $(TARGETS:=.build)

.PHONY: $(TARGETS:=.build)
$(TARGETS:=.build): %.build: docker-%
	-docker build -t $(REPO)/$* $<

wildfly.build: openjdk8.build
wildfly-oracle.build: wildfly.build docker-wildfly-oracle/modules/com/oracle/jdbc/main/ojdbc8.jar

.PHONY: run
run: wildfly.run

.PHONY: $(TARGETS:=.run)
$(TARGETS:=.run): %.run: %.build
	-docker run --rm -it -p 8443:8443 -p 9993:9993 $(REPO)/$*

.PHONY: clean
clean: $(TARGETS:=.clean)
$(TARGETS:=.clean): %.clean:
	-docker rmi -f $(REPO)/$*

.PHONY: clobber
clobber: clean
	-docker image prune -f
