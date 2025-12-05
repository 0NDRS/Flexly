import multer from 'multer'
import path from 'path'

// Use memory storage so we can access the buffer for Cloudinary and Gemini
const storage = multer.memoryStorage()

const checkFileType = (
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  const filetypes = /jpg|jpeg|png/
  const extname = filetypes.test(path.extname(file.originalname).toLowerCase())
  const mimetype = filetypes.test(file.mimetype)

  if (extname && mimetype) {
    return cb(null, true)
  } else {
    cb(new Error('Images only!'))
  }
}

const upload = multer({
  storage,
  fileFilter: function (req, file, cb) {
    checkFileType(file, cb)
  },
})

export default upload
