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
	
	var inputEditor = CodeMirror.fromTextArea
	(document.getElementById('inputTextArea'), { 
		lineNumbers: true,
		theme: 'dracula',
		mode:"text/x-java"
	});
	inputEditor.setSize(600, 450);
	var evaluator = CodeMirror.fromTextArea
	(document.getElementById('evaluatorTextArea'), { 
		lineNumbers: true,
		theme: 'dracula',
		mode:"text/x-java"
	});
	evaluator.setSize(600, 300);
	$("#clearInput").on("click", () => $("#confirmationModal").modal('show'));
	$("#confirmClear").on("click", () => inputEditor.setValue(""));
	$("#saveCode").on("click", () => saveCode(inputEditor.getValue()));
	$("#compileRun").on("click", ()=> compile('http://localhost:9090/compile',inputEditor.getValue()));
}

async function compile(url,code){
	$("#compileRun").prop("disabled",true);
	const response= await fetch(url,{
      "method": 'POST',
	  "Content-Type": "text/plain;charset=utf-8",
      body: code
    });
	const json= await response.json();
	$("#outputTextArea").val(json.result);
	$("#compileRun").prop("disabled",false);
}

async function writeAuthors(){
	//const authors = await fetch('/authors');
	//fillAuthors(await authors.json());
	const info = await fetch('/info');
	fillInfo(await info.json())
}
function fillInfo(json){
	const {team: team, nrc: nrc, version: version
		, projectSite: projectSite, repository:repository } = json; 
	$("#nrc").text(nrc);
	$("#group").text(team.code);
	$("#version").text(version);
	$("#repositoryLink").attr("href",repository);
	$("#site").attr("href",projectSite);
	$("#date").text("1/10/2020");
	fillAuthors(team);
}

function fillAuthors(team){
	const {members: members} = team; 
	$("#author1").text(members[0].Name+" "+members[0].Surnames+ " "+members[0].id);
	$("#author2").text(members[1].Name+" "+members[1].Surnames+ " "+members[1].id);
	$("#author3").text(members[2].Name+" "+members[2].Surnames+ " "+members[2].id);
}
function saveCode(code){
	var blob = new Blob([code], {type: "text/plain;charset=utf-8"});
	saveAs(blob, "code.java");
}

function showAbout(){
	writeAuthors();
	$("#aboutModal").modal('show');
}
function clearInput(){
	$("#outputTextArea").val('');
}
function clearOutput(){
	$("#outputTextArea").val('');
}
window.addEventListener("load", init_app, false);