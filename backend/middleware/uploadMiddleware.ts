import multer from 'multer'
import path from 'path'

// Use memory storage so we can access the buffer for Cloudinary and Gemini
const storage = multer.memoryStorage()

const checkFileType = (
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  // Allow jpeg, jpg, png, gif, webp, heic
  const filetypes = /jpeg|jpg|png|gif|webp|heic/
  const extname = filetypes.test(path.extname(file.originalname).toLowerCase())
  // Mimetype check can be unreliable depending on client, so we might rely mostly on extension or relax it
  const mimetype = /image\/.*/.test(file.mimetype)

  if (extname || mimetype) {
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
