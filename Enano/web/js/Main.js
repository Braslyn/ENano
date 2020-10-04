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
		theme: 'dracula',
		mode:"text/x-java"
	});
	inputEditor.setSize(600, 500);
	$("#clearInput").on("click", () => inputEditor.setValue(""));
	$("#saveCode").on("click", () => saveCode(inputEditor.getValue()));
	$("#compileRun").on("click", ()=> compile('http://localhost:9090/compile',inputEditor.getValue()));
}

async function compile(url,code){
	const response= await fetch(url,{
      "method": 'POST',
	  "Content-Type": "text/plain;charset=utf-8",
      body: code
    });
	const json= await response.json();
	
	$("#outputTextArea").val(json.result);
}

async function writeAuthors(){
	const authors = await fetch('/authors');
	fillAuthors(await authors.json());
	const info = await fetch('/info');
	fillInfo(await info.json())
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
	saveAs(blob, "code.java");
}

function showAbout(){
	$("#aboutModal").modal('show');
}
function clearOutput(){
	$("#outputTextArea").val('');
}
window.addEventListener("load", init_app, false);