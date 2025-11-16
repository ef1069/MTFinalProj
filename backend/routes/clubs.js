const express = require('express');
const Club = require('../models/Club');

const router = express.Router();

// list clubs
router.get('/', async (req, res) => {
  const clubs = await Club.find().populate('owner', 'name email').limit(100);
  res.json(clubs);
});

// create club
router.post('/', async (req, res) => {
  try {
    const { name, description } = req.body;
    const club = new Club({ name, description });
    await club.save();
    res.status(201).json(club);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// get club
router.get('/:id', async (req, res) => {
  try {
    const club = await Club.findById(req.params.id).populate('members', 'name email').populate('owner', 'name email');
    if (!club) return res.status(404).json({ message: 'Club not found' });
    res.json(club);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
