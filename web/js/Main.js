function init_app(){
	alert("xd")
	$("#about").click(showAbout);
    writeAuthors();
}

function writeAuthors(){
	fetch('http://localhost:3000/teste')
	.then(resp=> resp.json()).then(json=> console.log(json))
	.catch(e => console.log(e));
}

function showAbout(){
	$("#aboutModal").modal('show');
}

function writeModal(json){
	alert(json);
}
window.addEventListener("load", init_app, false);