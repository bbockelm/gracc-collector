gracc-collector: *.go
	go build -ldflags "-X main.build_date=`date -u +%Y%m%d.%H%M%S` -X main.build_ref=`git rev-parse --verify HEAD --short`" -o gracc-collector

scratch: *.go
	go build -ldflags "-X main.build_date=`date -u +%Y%m%d.%H%M%S`" -race -o gracc-collector.scratch

run:
	go build -ldflags "-X main.build_date=`date -u +%Y%m%d.%H%M%S`" -o gracc.run -race && ./gracc.run; rm -f gracc.run

test:
	cd gracc; go test

servertest: gracc-collector
	# run
	./gracc-collector -c gracc.cfg -l gracc.log &
	sleep 1
	# send ping
	curl -f http://localhost:8080/gratia-servlets/rmi\?command\=update\&arg1\=xxx\&from\=localhost\&bundlesize\=1
	@echo
	# send test bundle
	curl -f http://localhost:8080/gratia-servlets/rmi\?command\=update\&from\=localhost\&bundlesize\=10 --data-urlencode arg1@test.bundle
	@echo
	# cleanup
	killall  gracc-collector

clean:
	rm -f gracc-collector
