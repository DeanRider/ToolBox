Math.m = {};

Math.m.T = function(a) { // matrix transpose
	var b = [], m = a.length, n = a[0].length; // m rows and n cols
	for (var j = 0; j < n; ++j) b[j] = [];
	for (var i = 0; i < m; ++i)
		for (var j = 0; j < n; ++j)
			b[j].push(a[i][j]);
	return b;
}

Math.m.mul = function(a, b) { // matrix mul
	var m = a.length, n = a[0].length, s = b.length, t = b[0].length;
	if (n != s) return null;
	var x = [], c = Math.m.T(b);
	for (var i = 0; i < m; ++i) {
		x[i] = [];
		for (var j = 0; j < t; ++j) {
			var sum = 0;
			var ai = a[i], cj = c[j];
			for (var k = 0; k < n; ++k) sum += ai[k] * cj[k];
			x[i].push(sum);
		}
	}
	return x;
}

var n = 100;
if (arguments[0]) n = parseInt(arguments[0]);

function matgen() {
	var a = []
	for (i = 0; i < n; ++i) {
		a[i] = []
		for (j = 0; j < n; ++j)
			a[i][j] = 2 * Math.random() - 1
	}
	return a;
}

var a = matgen();
var b = matgen();

var c = Math.m.mul(a, b);
