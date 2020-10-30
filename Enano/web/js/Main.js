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
	$("#outputTextArea").val('');
}

async function compile(url,code){
	if(code!==""){
		let formData = new FormData()
		await formData.append('text',code);
		$("#compileRun").prop("disabled",true);
		const response= await fetch(url,{
		  "method": 'POST',
		  'Content-Type': 'multipart/form-data',
		  body: formData
		});
		const json= await response.json();
		$("#outputTextArea").val(json.result);
		$("#compileRun").prop("disabled",false);
	}else{
		$("#outputTextArea").val("Text something");
	}
}

async function writeAuthors(){
	//const authors = await fetch('/authors');
	//fillAuthors(await authors.json());
	const info = await fetch('http://localhost:9090/info');
	fillInfo(await info.json())
}
function fillInfo({team,nrc,version,projectSite,repository}){
	$("#nrc").text(nrc);
	$("#group").text(team.code);
	$("#version").text(version);
	$("#repositoryLink").attr("href",repository);
	$("#site").attr("href",projectSite);
	$("#date").text("1/10/2020");
	fillAuthors(team);
}

function fillAuthors({members}){
	let index=1;
	members.forEach( (member)=> $("#author"+index++).text(member.Name+" "+member.Surnames+" "+member.id) )
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