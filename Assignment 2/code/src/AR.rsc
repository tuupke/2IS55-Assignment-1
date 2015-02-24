module AR
 
import lang::java::jdt::JDT;  // this module provides the API for extracting Java models
import lang::java::jdt::Java; // this module provides the model for Java
 
import Relation; // a stdlib module with practical API on relations
 
// these modules are needed to visualize graphs in the IDE
import vis::Figure;
import vis::Render;
 
// for debug println, writeFile, etc.
import IO;
 
@doc{
  Here we extract information from the Eclipse JDT, re-order it a bit and generate a "Figure" 
  which can be rendered directly in the IDE. Figure also allows for interaction such as 
  hyperlinking to the source code, but this is not shown here.
}
public void drawDiagram(loc p) {
  int i = 0;
  int id() { i += 1; return i; } // a local function to generate unique id's
  
  inf = extractProject(p); // this gets the information about all Java classes in project p
  classes = inf@classes<1> + carrier(inf@extends); // we add the classes that p depends on
  ids = ( cl : id() | cl <- classes ); // a map comprehension for unique id's
  
  classFigures = [box(text(readable(cl)), id("<ids[cl]>")) | cl <- classes]; // this list comprehension generates labeled graph nodes
  edges = [edge("<ids[to]>", "<ids[from]>") | <from,to> <- inf@extends ];  // this list comprehension produces edges
  
  // finally we build the graph with some default styling options and a layout algorithm, and then render it
  render(graph(classFigures, edges, hint("layered"), std(gap(10)), std(font("Bitstream Vera Sans")), std(fontSize(8))));
}
 
@doc{
  Here we extract information from the Eclipse JT, re-order it a bit a generate a Graphviz dot graph,
  which can then be rendered to a png, pdf, or whatever.
}
public str dotDiagram(loc p) {
  int i = 0;
  int id() { i += 1; return i; } // a local function to generate unique id's
  
  inf = extractProject(p); // this gets the information about all Java classes in project p
  classes = inf@classes<1> + carrier(inf@extends); // we add the classes that p depends on
  ids = ( cl : id() | cl <- classes );  // generate a map with id codes
  
  return "digraph classes {
         '  fontname = \"Bitstream Vera Sans\"
         '  fontsize = 8
         '  node [ fontname = \"Bitstream Vera Sans\" fontsize = 8 shape = \"record\" ]
         '  edge [ fontname = \"Bitstream Vera Sans\" fontsize = 8 ]
         '
         '  <for (cl <- classes) { /* a for loop in a string template, just like PHP */>
         '  N<ids[cl]> [label=\"{<readable(cl) /* a Rascal expression between < > brackets is spliced into the string */>||}\"]
         '  <} /* this is the end of the for loop */>
         '
         '  <for (<from, to> <- inf@extends) {>
         '  N<ids[to]> -\> N<ids[from]> [arrowhead=\"empty\"]<}>
         '}";
}
 
public void showDot(loc p) = showDot(p, |home:///<p.authority>.dot|);
 
public void showDot(loc p, loc out) {
  writeFile(out, dotDiagram(p));
}