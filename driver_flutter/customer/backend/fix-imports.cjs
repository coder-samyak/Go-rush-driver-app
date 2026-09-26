const fs = require('fs');
const path = require('path');

function walk(dir, done) {
  let results = [];
  fs.readdir(dir, function(err, list) {
    if (err) return done(err);
    let i = 0;
    (function next() {
      let file = list[i++];
      if (!file) return done(null, results);
      file = path.resolve(dir, file);
      fs.stat(file, function(err, stat) {
        if (stat && stat.isDirectory()) {
          walk(file, function(err, res) {
            results = results.concat(res);
            next();
          });
        } else {
          results.push(file);
          next();
        }
      });
    })();
  });
}

walk(path.join(__dirname, 'src'), function(err, results) {
  if (err) throw err;
  results.filter(f => f.endsWith('.ts')).forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    
    // Fix relative imports (e.g. from './file')
    let updated = content.replace(/from\s+['"](\.[^'"]+)['"]/g, (match, p1) => {
      if (p1.endsWith('.js') || p1.endsWith('.json')) {
        return match;
      }
      
      // Check if p1 refers to a directory (with an index.ts file) or a specific file
      let targetPath = path.resolve(path.dirname(file), p1);
      if (fs.existsSync(targetPath) && fs.statSync(targetPath).isDirectory()) {
          return `from '${p1}/index.js'`;
      }
      return `from '${p1}.js'`;
    });
    
    // Fix dynamic imports (e.g. import('./file'))
    updated = updated.replace(/import\s*\(\s*['"](\.[^'"]+)['"]\s*\)/g, (match, p1) => {
       if (p1.endsWith('.js') || p1.endsWith('.json')) {
        return match;
      }
      let targetPath = path.resolve(path.dirname(file), p1);
      if (fs.existsSync(targetPath) && fs.statSync(targetPath).isDirectory()) {
          return `import('${p1}/index.js')`;
      }
      return `import('${p1}.js')`;
    });
    
    if (content !== updated) {
      fs.writeFileSync(file, updated, 'utf8');
      console.log(`Updated ${file}`);
    }
  });
});
