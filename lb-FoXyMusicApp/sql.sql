CREATE TABLE IF NOT EXISTS `lb_music` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenID` varchar(50) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;