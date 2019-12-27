DRAFT:=shg-mud-quarantine
VERSION:=$(shell ./getver ${DRAFT}.mkd )
YANGDATE=2019-07-08
YANGFILE=cira-shg-mud
CWTDATE1=yang/${YANGFILE}@${YANGDATE}.yang
PYANG=pyang

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

${CWTDATE1}:: ${YANGFILE}.yang
	mkdir -p yang
	sed -e"s/YYYY-MM-DD/${YANGDATE}/" ${YANGFILE}.yang > ${CWTDATE1}

${YANG}-tree.txt: ${CWTDATE1}
	-${PYANG} -f tree --path=yang --tree-print-groupings --tree-line-length=70 ${CWTDATE1} > ${YANGFILE}-tree.txt

%.xml: %.mkd ${CWTDATE1} #${YANG}-tree.txt
	kramdown-rfc2629 ${DRAFT}.mkd | ./insert-figures >${DRAFT}.xml
	: git add ${DRAFT}.xml

%.txt: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc $? $@

%.html: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --html -o $@ $?

submit: ${DRAFT}.xml
	curl -S -F "user=mcr+ietf@sandelman.ca" -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submit

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}.xml ${CWTDATE1}

yang/ietf-mud@2019-01-28.yang:
	mkdir -p yang
	(cd yang && wget https://raw.githubusercontent.com/YangModels/yang/master/standard/ietf/RFC/ietf-mud@2019-01-28.yang )

yang/ietf-acldns@2019-01-28.yang:
	mkdir -p yang
	(cd yang && wget https://raw.githubusercontent.com/YangModels/yang/master/standard/ietf/RFC/ietf-acldns@2019-01-28.yang )

yang/ietf-access-control-list@2019-03-04.yang:
	mkdir -p yang
	(cd yang && wget https://raw.githubusercontent.com/YangModels/yang/master/standard/ietf/RFC/ietf-access-control-list@2019-03-04.yang )

${CWTDATE1}:: yang/ietf-mud@2019-01-28.yang yang/ietf-acldns@2019-01-28.yang yang/ietf-access-control-list@2019-03-04.yang

.PRECIOUS: ${DRAFT}.xml
