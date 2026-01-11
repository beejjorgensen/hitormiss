.PHONY: run

run: hitormiss.prg
	x64 -basicload $<

hitormiss.prg: hit_or_miss_c64.bas
	tr '[:upper:]' '[:lower:]' < $< | petcat -w2 -o $@ --
	
