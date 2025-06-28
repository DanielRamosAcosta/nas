TYPST = typst
DOC_SRC = docs/NAS\ DIY.typ
DOC_PDF = docs/NAS\ DIY.pdf

docs: $(DOC_PDF)

$(DOC_PDF): $(DOC_SRC)
	$(TYPST) compile "$<"
