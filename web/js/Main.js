/*
	Authors:
		Enrique Mendez Cabezas
		Braslyn Rodriguez Ramirez
		Philippe Gairaud Quesada

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
	fetch('http://localhost:3000/teste')
	.then(resp=> resp.json()).then(json=> fillModal(json))
	.catch(e => console.log(e));
}
function fillModal(json){
	$("#author1").text(json.text[0]);
	$("#author2").text(json.text[1]);
	$("#author3").text(json.text[2]);
	$("#nrc").text(json.text[3]);
	$("#group").text(json.text[4]);
	$("#version").text(json.text[5]);
	$("#repositoryLink").attr("href",json.text[6]);
	$("#date").text(json.text[7]);
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