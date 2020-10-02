/*
	Authors:
		Enrique Mendez Cabezas 117390080
		Braslyn Rodriguez Ramirez 402420750
		Philippe Gairaud Quesada 117290193

	Apis: 
		https://codemirror.net/
		https://github.com/eligrey/FileSaver.js/
*/
function init_app(){
	$("#about").click(showAbout);
	writeAuthors();
	var inputEditor = CodeMirror.fromTextArea
	(document.getElementById('inputTextArea'), { 
		lineNumbers: true,
		theme: 'dracula' 
	});
	inputEditor.setSize(600, 500);
	$("#clearInput").on("click", () => inputEditor.setValue(""));
	$("#saveCode").on("click", () => saveCode(inputEditor.getValue()));
}

function writeAuthors(){
	fetch('http://localhost:5231/authors')
	.then(resp=> resp.json()).then(json=> fillAuthors(json))
	.catch(e => console.log(e));
		fetch('http://localhost:5231/info')
	.then(resp=> resp.json()).then(json=> fillInfo(json))
	.catch(e => console.log(e));
	
}
function fillInfo(json){
	$("#nrc").text(json.NRC);
	$("#group").text(json.group);
	$("#version").text(json.version);
	$("#repositoryLink").attr("href",json.repository);
	$("#date").text("1/10/2020");
}

function fillAuthors(json){
	$("#author1").text(json[0].name+" "+json[0].ID);
	$("#author2").text(json[1].name+" "+json[1].ID);
	$("#author3").text(json[0].name+" "+json[0].ID);
}
function saveCode(code){
	var blob = new Blob([code], {type: "text/plain;charset=utf-8"});
	saveAs(blob, "code.txt");
}

function showAbout(){
	$("#aboutModal").modal('show');
}
function clearOutput(){
	$("#outputTextArea").val('');
}
window.addEventListener("load", init_app, false);