const Post = require('../models/Post');
const multer = require('multer');
const storage = require('../utils/cloudinaryStorage');

const upload = multer({ storage: storage });

exports.createPost = [
  upload.single('postphoto'),
  async (req, res) => {
    try {
      const { PostName, UserId, Posttitle, Discription, createdAt } = req.body;

      if (!req.file) {
        return res.status(400).json({ error: 'Photo is required' });
      }

      const postData = {
        PostName,
        UserId,
        Posttitle,
        Discription,
        postphoto: req.file.path, // Cloudinary URL
        createdAt: createdAt ? new Date(createdAt) : new Date(),
        likeCount: 0,
      };

      const newPost = new Post(postData);
      await newPost.save();
      res.status(201).json(newPost);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message, stack: error.stack });
    }
  }
];

exports.getAllPosts = async (req, res) => {
  try {
    const posts = await Post.find();
    res.status(200).json(posts);
  } catch (error) {
    res.status(500).json({ error: error.message, stack: error.stack });
  }
};

exports.getPostById = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ error: 'Post not found' });
    res.status(200).json(post);
  } catch (error) {
    res.status(500).json({ error: error.message, stack: error.stack });
  }
};
