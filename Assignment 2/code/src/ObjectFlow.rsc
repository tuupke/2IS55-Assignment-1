module flowUnit

import List;
import Relation;
import lang::java::m3::Core;
 
import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST; 
import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import IO;
import vis::Figure; 
import vis::Render;
import Prelude;
import Type;
 
alias OFG = rel[loc from, loc to];
	
public OFG buildGraph(Program p) 
	= { <as[i], fps[i]> | newAssign(x, cl, c, as) <- p.statements, constructor(c, fps) <- p.decls, i <- index(as) }
	+ { <cl + "this", x> | newAssign(x, cl, _, _) <- p.statements }
	+ { <y, x>| assign(x, _, y) <- p.statements}
	+ { <y, m + "this"> | call(_, _, y, m, _) <- p.statements}
	+ { <as[i], fps[i]> | call(_, _, _, m, as) <- p.statements, method(m, fps) <- p.decls, i <- index(as) }
	+ { <m + "return", x> | call(x, _, _, m, _) <- p.statements };
		 
OFG prop(OFG g, rel[loc,loc] gen, rel[loc,loc] kill, bool back) {
	OFG IN = { };
	OFG OUT = gen + (IN - kill);
	gi = g<to,from>;
	set[loc] pred(loc n) = gi[n];
	set[loc] succ(loc n) = g[n];
	
	solve (IN, OUT) {
		IN = { <n,\o> | n <- carrier(g), p <- (back ? pred(n) : succ(n)), \o <- OUT[p] };
		OUT = gen + (IN - kill);
	}
	
	return OUT;
}

tuple[rel[loc, loc] dependencies, rel[loc, loc] associations] getObjectFlowUnit(Program p, M3 M3model){
	OFG ofg = buildGraph(p);
	
	associationss = {};
	dependenciess = {};
	kill = {};
	
	// We want only actually referenced object, so we implement figure 3.2 from the book.
	gen = {<class + "this", class> | newAssign(_,class, _, _) <- p.statements && class in classes(M3model)};

	OFG propagationForwards = prop(ofg, gen, kill, false);
	OFG propagationBackwards = prop(ofg, gen, kill, true);

	associationss += OFGtoAssociations(propagationForwards, M3model);
	associationss += OFGtoAssociations(propagationBackwards, M3model);
	
	dependenciess += OFGtoDependencies(propagationForwards, M3model);
	dependenciess += OFGtoDependencies(propagationBackwards, M3model);
	
	
	// Since we want to check for weakly typed containers, we implement 
	// figure 3.4 for forwards (which is the same as figure 3.2)
	// and figure 3.5 for backwards
	
	weaklyForwardGen = gen;
	weaklyBackwardGen =  {<class, cast> | assign(_, cast, class) <- p.statements, cast in classes(M3model)};
	weaklyBackwardGen += {<method + "return", cast> | call(_, cast, _, method) <- p.statements, cast in classes(M3model)};
	
	OFG weaklyPropForwards = prop(ofg, weaklyForwardGen, kill, false);
	OFG weaklyPropBackwards = prop(ofg, weaklyBackwardGen, kill, true);
	
	associationss += OFGtoAssociations(weaklyPropForwards, M3model);
	associationss += OFGtoAssociations(weaklyBackwardGen, M3model);
	
	dependenciess += OFGtoDependencies(weaklyPropForwards, M3model);
	dependenciess += OFGtoDependencies(weaklyBackwardGen, M3model);
	
	// Cleanup
	// Remove potential classes which are not present in project
	associationss = {<from, to> | <from, to> <- associationss && from in classes(M3model) && to in classes(M3model)};
	dependenciess = {<from, to> | <from, to> <- dependenciess && from in classes(M3model) && to in classes(M3model)}; 

	// Remove selfloops
	associationss = removeSelfLoops(associationss);
	dependenciess = removeSelfLoops(dependenciess);

	return <dependenciess, associationss>;
} 

public OFG removeSelfLoops(OFG ofg){
	// Probably could have done with set operations, but this works too
	toReturn = ofg;
	
	for(tuple[loc from, loc to] tup <- ofg) {
		if(tup.from == tup.to) {
			toReturn -= tup;
		}
	}
	
	return toReturn;
}

public rel[loc, loc] OFGtoAssociations(OFG ofg, M3 M3model){
	// Associations are of the form: class A { B b; } 
	fieldss = {<fieldn, clsss> | <fieldn, clsss> <- ofg, fieldn.scheme == "java+field"};
	return {<from, clsss> | <from, to> <- M3model@containment, <to, clsss> <- fieldss, clsss in classes(M3model)};
}

public rel[loc, loc] OFGtoDependencies(OFG ofg, M3 M3model){
	// Dependencies are of the form: class A { void f(B b) {b.g(); } } 
	// and: class A { void f() {B b; … b.g();} } 

	// Get all parameters and variables
	parames = {<from, to> | <from, to> <- ofg, from.scheme == "java+parameter"};
	variabes = {<from, to> | <from, to> <- ofg, from.scheme == "java+variable", to in classes(M3model)};
	
	// Get the methods for the parameters and the variables
	methodParams = {<from, to> | <from, to> <- M3model@containment, <a, to> <- parames, a in classes(M3model)};
	methodVarias = {<method, to> | <method, variable> <- M3model@containment, <variable, to> <- variabes};
	
	return {<a, c> | <a, method> <- M3model@containment, <method, c> <- methodParams}
		 + {<a, b> | <a, method> <- M3model@containment, <method, b> <- methodVarias};
}