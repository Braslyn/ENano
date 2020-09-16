function init_app(){
	$("#about").click(showAbout);
	writeAuthors();
	var inputEditor = CodeMirror.fromTextArea
	(document.getElementById('inputTextArea'), { 
		lineNumbers: true,
		theme: 'cobalt' 
	});
	inputEditor.setSize(600, 500);


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


function showAbout(){
	$("#aboutModal").modal('show');
}

function writeModal(json){
	alert(json);
}
window.addEventListener("load", init_app, false);