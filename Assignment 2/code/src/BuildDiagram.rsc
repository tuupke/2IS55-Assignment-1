module BuildDiagram

import List;
import Relation;
import Exception;
import Set;
import String;
import Type;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST; 
import lang::ofg::ast::FlowLanguage;
import lang::java::m3::TypeSymbol;
import lang::ofg::ast::Java2OFG;
import IO;
import ObjectFlow;

// Settings from FlowGraphsAndClassDiagrams.rsc
str settings = "digraph classes {
         '  fontname = \"Bitstream Vera Sans\"
         '  fontsize = 8
         '  node [ fontname = \"Bitstream Vera Sans\" fontsize = 8 shape = \"record\" ]
         '  edge [ fontname = \"Bitstream Vera Sans\" fontsize = 8 ]";
         
str realisation = "edge[arrowhead = \"empty\"; style = \"dashed\"]\n";
str generalization = "edge[arrowhead = \"empty\"; style= \"solid\"]\n";
str association = "edge[arrowhead = \"open\"; style = \"solid\"]\n";
str dependency = "edge[arrowhead = \"open\"; style = \"dashed\"]\n";

public str prettifyRelations(rel[loc, loc] relations, rel[loc, str] M3modelInvert){
	str toReturn = "";
	
	for(tuple[loc, loc] relation <- relations){
		try {
			//str className = getOneFrom(M3modelInvert[relation[0]]);
			//str classPos = relation[0].parent.file + getOneFrom(M3modelInvert[relation[0]]);
		
			str from = relation[0].parent.file + getOneFrom(M3modelInvert[relation[0]]);
			str to = relation[1].parent.file + getOneFrom(M3modelInvert[relation[1]]);
			toReturn += "<from> -\> <to>;
";
			
		} catch EmptySet() : {
			print("");
			//println("Probably the anonymous class, is a default Java thing. Could choose to add AccessController here.");
		}
	}
	return toReturn;
}


public str convertM3ToUML(str accessLevel, str toConvert){
	// Strip the () from the end of accessLevel
	accessLevel = reverse(substring(reverse(accessLevel),2)); 

	switch(accessLevel){
		case "private":
			return " -  <toConvert>";
		case "protected":
			return "# <toConvert>";
		case "static":
			return "_<toConvert>_"; // Underlines are apparently tough in dot
		case "final":
			return toUpperCase(toConvert);
		case "public":
			return "+ <toConvert>";
	}
	
	// In case all else fails (fuck default in switches)
	return "? <toConvert>";
}

public str getClassFields(loc classLoc, M3 M3model, rel[loc, str] M3modelInvert){
	// Fields in UML consists of <field access> <name> : <type> 
	// so we have to build this for every field
	
	str toReturn = "";
	
	// Get all fields
	set[loc] fields = { f | f <- M3model@containment[classLoc], f.scheme == "java+field"};

	// Get the types and modifiers of the fields
	types = domainR(M3model@types, fields);
	modifiers = domainR(M3model@modifiers, fields);
	
	list[loc] fieldsList = sort(toList(fields));
	
	//Loop through the found field locations
	for(loc field <- fieldsList){
		// Get the fieldname
		str fieldName = getOneFrom(M3modelInvert[field]);
		
		// Get the field name modifiers (public, private, static, ...)
		// Since we are doing operations over the name, we have to iterate over the modifiers backwards
		list[Modifier] fieldModifiers = reverse(sort(toList(modifiers[field])));

		// Convert the field name and modifiers to the UML version
		for(Modifier modifier <- fieldModifiers){
			fieldName = convertM3ToUML("<modifier>", fieldName);
		}
		
		// Append the return type
		str returnType = convertTypeSymbolToHuman(toList(types[field])[0], M3modelInvert);
				
		// Build the field string and append to toReturn
		toReturn += "<fieldName> : <returnType>\\l";
	}
	
	return toReturn;
}

// Return all class methods in DOT format
public str getClassMethods(loc classLoc, M3 M3model, rel[loc, str] M3modelInvert){

	// Method in a UML class consist of <method access> <name> : <type>
	// so we have to build this for every method
	
	// Get all constructors
	set[loc] constructors = { c | c <- M3model@containment[classLoc], c.scheme == "java+constructor"};
	
	// Get all methods
	set[loc] methodsSet = { m | m <- M3model@containment[classLoc], m.scheme == "java+method"};
	
	// Get all method types, used for the return type of the methods
	methodTypes = domainR(M3model@types, methodsSet);
		
	// Get all method modifiers
	methodModifiers = domainR(M3model@modifiers, methodsSet);
	
	list[loc] methods = sort(toList(methodsSet));
	
	str toReturn = "";
	
	// First all all constructors
	for(loc constructor <- constructors){
		// Get the constructor name
		str name = getOneFrom(M3modelInvert[constructor]);
		
		// Get the constructor modifiers and modify <name> with them
		list[Modifier] modifiers = reverse(sort(toList(methodModifiers[constructor])));
		
		for(Modifier modifier <- modifiers){
			name = convertM3ToUML("<modifier>", name);
		}
		
		// Get the constructor parameters
		str parameters = "";
		//Build the parameters string
		list[loc] params = [p | p <- M3model@containment[constructor], p.scheme == "java+parameter"];
		for(loc parameter <- params){
			TypeSymbol parameterType = toList(M3model@types[parameter])[0];
			str parameterName = getOneFrom(M3modelInvert[parameter]);
				
			parameters += "<parameterName>: <convertTypeSymbolToHuman(parameterType, M3modelInvert)>, ";
		}
		
		if(size(params) > 0){
			parameters = reverse(substring(reverse(parameters),2));//substring(method_params_str, 0, size(method_params_str) - 2);
		}
		
		// Add the constructor
		toReturn += "Const <name>(<parameters>)\\l";

	}
	
	// Then add all methods
	for(loc method <- methods){
		// Get the constructor name
		
		str name = getOneFrom(M3modelInvert[method]);
		
		// Get the constructor modifiers and modify <name> with them
		list[Modifier] modifiers = reverse(sort(toList(methodModifiers[method])));
		
		for(Modifier modifier <- modifiers){
			name = convertM3ToUML("<modifier>", name);
		}
		
		// Get the method parameters
		str parameters = "";
		//Build the parameters string
		list[loc] params = [p | p <- M3model@containment[method], p.scheme == "java+parameter"];
		for(loc parameter <- params){
			TypeSymbol parameterType = toList(M3model@types[parameter])[0];
			str parameterName = getOneFrom(M3modelInvert[parameter]);
				
			parameters += "<parameterName>: <convertTypeSymbolToHuman(parameterType, M3modelInvert)>, ";
		}
		
		if(size(params) > 0){
			// Strip the last 2 characters
			parameters = reverse(substring(reverse(parameters),2));
		}
		
		// Build the returntype
		str returnType = convertTypeSymbolToHuman(toList(methodTypes[method])[0][2], M3modelInvert);
		
		// Add the method
		toReturn += "<name>(<parameters>) : <returnType>\\l";
	}
	
	return toReturn;
}

public str buildClass(loc classLoc, M3 M3model, rel[loc, str] M3modelInvert){
	str ret = "";
	
	str className = getOneFrom(M3modelInvert[classLoc]);
	str classPos = classLoc.parent.file + className;
	
	ret += "<classPos> [\n";
	ret += "label = \"{<className>|";
	ret += getClassFields(classLoc, M3model, M3modelInvert);
	ret += "|";
	ret += getClassMethods(classLoc, M3model, M3modelInvert);
	ret += "}\"\n";
	ret += "]\n";
	
	return ret;
}

public str renderProject(loc location){

	str dotContents = settings;
	
	M3 M3model = createM3FromEclipseProject(location);
	
	rel[loc,str] M3modelInvert = (invert(M3model@names));
	
	// Adding classes
	list[loc] classes = toList(classes(M3model));
	for(loc class <- classes){
		dotContents += buildClass(class, M3model, M3modelInvert);
	}
	
	// Add the generatlizations
	rel[loc,loc] generalizations = M3model@extends;
	generalizations -= {<a, b> | <a, b> <- generalizations, a == b || a notin classes || b notin classes};
	//generalizations = {<a, b> | <a, b> <- generalizations, a in classes && b in classes};
	dotContents += generalization;
	dotContents += prettifyRelations(generalizations, M3modelInvert);
	
	// Add the realizations
	rel[loc, loc] realisations = M3model@implements;
	realisations -= {<a, b> | <a, b> <- realisations, a==b || a notin classes || b notin classes};
	//realisations = {<a, b> | <a, b> <- realisations, a in classes, b in classes};
	dotContents += realisation;
	dotContents += prettifyRelations(realisations, M3modelInvert);
	
	// -- Tricky part which relies on the object flow graph --
	// Compute everything from the flowgraph using the algorithm in the slides/book
	Program p = createOFG(location);
	tuple[rel[loc,loc] associations, rel[loc,loc] dependencies] flow = getObjectFlowUnit(p, M3model);
	
	// Add the associations
	rel[loc,loc] associations = flow[1] - realisations - generalizations;
	associations -= {<from, to> | <from, to> <- associations, from == to};
	dotContents += association;
	dotContents += prettifyRelations(associations, M3modelInvert);
	
	// Add the dependencies
	rel[loc,loc] dependenci = flow[0] - associations - realisations - generalizations;
	dependenci -= {<from, to> | <from, to> <- dependenci, from == to || from notin classes || to notin classes};
	dotContents += dependency;
	dotContents += prettifyRelations(dependenci, M3modelInvert);
	
	dotContents += "}";
	return dotContents;
}


public void buildForProject(loc project, loc fileLocation){
	writeFile(fileLocation, renderProject(project));
}

public void buildForProject(loc project){
	buildForProject(project, |home:///classDiagram.dot|);
}

// Convert unreadable Typesymbol to user friendly unit.
public str convertTypeSymbolToHuman(TypeSymbol t, rel[loc,str] M3modelInvert){
	switch(t){
		case \int(): return "int";
		case \short(): return "short";
		case \boolean(): return "boolean";
		case \long(): return "long";
		case \char(): return "char";
		case \byte(): return "byte";
		case \array(objectName, dimensionality): {
			str retStr = "array[<dimensionality>](";
			retStr += convertTypeSymbolToHuman(objectName, M3modelInvert);
			retStr += ")";
			return retStr;
		}
		case \class(className, tList): {
			if(size(tList)!=0){
				// If this gets triggered, the switch needs updating
				println("Holy guacamole");
			}
			return getOneFrom(M3modelInvert[className]);
		}
		case \interface(className, tList): {
			if(size(tList)!=0){
				// If this gets triggered, the switch needs updating
				println("Holy guacamole");	
			}
			return getOneFrom(M3modelInvert[className]);
		}
		case \object(): return "object";
		case \void(): return "void";
	}

	// If this gets triggered, the switch needs updating
	println("Typesymbolconverter unit needs work: <t> not present");
	return "?";
}

public void doAll(){
	buildForProject(|project://eLib|, |home:///TUe/2IS55%20-%20Software%20Evolution/Assignment%202/report/dotFiles/eLib.dot|);
	buildForProject(|project://nekohtml-0.9.5|, |home:///TUe/2IS55%20-%20Software%20Evolution/Assignment%202/report/dotFiles/nekohtml-0.9.5.dot|);
	buildForProject(|project://nekohtml-1.9.21|, |home:///TUe/2IS55%20-%20Software%20Evolution/Assignment%202/report/dotFiles/nekohtml-1.9.21.dot|);
}
