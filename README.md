# schematron4word
Schematron validation for OOXML/ODF word-processing documents

## Running with Ant
1. Run `build.xml` (for OOXML) or `build-ODF.xml` (for ODF): these will use the (N.B. OOXML-specific!) demo document and Schematron schema by default.
  1. You can specify your own document and schema by overriding the properties `$wordml.file` and `$schema`:
    * either at the command line (`-Dwordml.file=my-wordml-file.xml` etc.)
    * or in `properties.local.xml`, of which an example is provided.
1. The annotated version of the original is emitted as `[filename]-ANNOTATED.xml`.

_Tested with \<oXygen/> 17.1/Ant 1.9.3_
