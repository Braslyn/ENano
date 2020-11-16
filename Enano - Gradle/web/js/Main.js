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
	inputEditor.setSize(600, 500);
	var evaluator = CodeMirror.fromTextArea
	(document.getElementById('evaluatorTextArea'), { 
		lineNumbers: true,
		theme: 'dracula',
		mode:"text/x-java"
	});
	evaluator.setSize(600, 300);
	var out = CodeMirror.fromTextArea
	(document.getElementById('outputTextArea'), { 
		lineNumbers: true,
		theme: 'dracula',
		mode:"text/x-java"
	});
	out.setSize(600, 600);
	$("#clearInput").on("click", () => $("#confirmationModal").modal('show'));
	$("#confirmClear").on("click", () => inputEditor.setValue(""));
	$("#ClearOutPut").on("click", () => out.setValue(""));
	$("#saveCode").on("click", () => saveCode(inputEditor.getValue()));
	//$("#compileRun").on("click", ()=> compile('http://localhost:3030/transpile',inputEditor.getValue()));
	$("#compileRun").on("click", ()=> $("#nameModal").modal('show'));
	$("#finalRun").on("click", ()=> compile('http://localhost:3030/transpile',inputEditor.getValue(),out));
	evaluator.on("keypress",()=> SendEvaluator(event,evaluator));
}

async function compile(url,code,output){
	if(code!==""){
		let fileName = $("#name").val();
		let formData = new FormData();
		await formData.append('name',fileName);
		await formData.append('text',code);
		//alert(formData.getAll('name'));
		$("#compileRun").prop("disabled",true);
		const response= await fetch(url,{
		  "method": 'POST',
		  'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
		  body: formData
		});
		const json= await response.json();
		output.getDoc().setValue(json.result);
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


function SendEvaluator(event,evaluator){
	var key = window.event.keyCode;
	//alert(evaluator.getDoc().getValue())
	if (key === 13) {
        Evaluator(evaluator.getDoc().getValue(),evaluator);
    }
}

async function Evaluator(code,evaluator){
	let fileName = $("#line").val();
	let formData = new FormData();
	let line=code.split('\n');
	await formData.append('line',line[line.length-1]);
	const response= await fetch('http://localhost:3030/evaluate',{
	  "method": 'POST',
	  'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
	  body: formData
	});
	const json= await response.json();
	evaluator.getDoc().setValue(code+'\n'+json.result);
}

function fillAuthors({members}){
	let index=1;
	members.forEach( (member)=> $("#author"+index++).text(member.Name+" "+member.Surnames+" "+member.id) )
}
function saveCode(code){
	var blob = new Blob([code], {type: "text/plain;charset=utf-8"});

	saveAs(blob, 'file.no');
}

function showAbout(){
	writeAuthors();
	$("#aboutModal").modal('show');
}
function clearInput(){
	$("#outputTextArea").val('');
}
function clearOutput(){
	$("#outputTextArea").setValue('');
}
window.addEventListener("load", init_app, false);