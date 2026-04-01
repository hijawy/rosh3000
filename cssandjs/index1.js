const fs = require('fs');
const path = require('path');
const directory = './';

// use readdir method to read the files of the direcoty 
fs.readdir(directory, (err, files) => {
  files.forEach(file => {
    // get the details of the file 
    let fileDetails = fs.lstatSync(path.resolve(directory, file));
    // check if the file is directory 
    if (fileDetails.isDirectory()) {
      console.log('Directory: ' + file);
    } else {
      console.log('File: ' + file);
    }
  });
});