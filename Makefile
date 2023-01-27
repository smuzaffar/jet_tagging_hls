.DEFAULT_GOAL := all
CC=g++
CXXFLAGS=-O3 -fPIC -std=c++17
PROJECT:=jet_tagger
MODEL_VERSION_PREFIX:=v
SKIP_VERSIONS:=
LDFLAGS=
INCFLAGS=-I${HLS_INCDIR}
ALL_VERSIONS:=$(filter-out $(SKIP_VERSIONS),$(foreach v,$(wildcard $(MODEL_VERSION_PREFIX)*),$(if $(strip $(wildcard $(v)/firmware)),$v)))

#Build rules for each model version
define build_rule
$1_obj:=$(patsubst %.cpp,%.o,$(wildcard $1/*.cpp) $(wildcard $1/firmware/*.cpp))
all_libs+=lib/$(PROJECT)_$(1).so
lib/$(PROJECT)_$(1).so: $$($1_obj)
	@[ -d $$(@D) ] || mkdir -p $$(@D)
	${CC} ${CXXFLAGS} ${LDFLAGS} -shared $$^ -o $$@
clean::
	rm -rf $$($1_obj) lib
endef

#Collection of all versions libs
all_libs:=

#Add build rules for every version
$(foreach v,$(ALL_VERSIONS),$(eval $(call build_rule,$v)))

all: $(all_libs)
	@echo All done

%.o: %.cpp
	${CC} -c ${CXXFLAGS} ${INCFLAGS} $^ -o $@
