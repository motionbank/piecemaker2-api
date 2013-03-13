SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';




INSERT INTO `events` (`id`, `event_group_id`, `created_by_user_id`, `utc_timestamp`, `duration`) VALUES
(502, 501, 500, '0.000000', '0.000000');

INSERT INTO `event_fields` (`event_id`, `id`, `value`) VALUES
(502, 'type', 'whatever');


INSERT INTO `event_groups` (`id`, `title`, `text`) VALUES
(501, 'Event Group 1', 'some description');

INSERT INTO `users` (`id`, `name`, `email`, `password`, `api_access_key`, `is_admin`, `is_disabled`) VALUES
(500, 'Hans', 'hans@example.com', '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8', '6a66515fcc6b585a69df6b50805146cf8fb91b9c', 1, 0)
, (600, 'Peter', 'peter@example.com', '57443a4c052350a44638835d64fd66822f813319', '0acbc5bc1a0e5fc7390f4ea91500eba665998ef7', 1, 0);


INSERT INTO `user_has_event_groups` (`user_id`, `event_group_id`, `allow_create`, `allow_read`, `allow_update`, `allow_delete`) VALUES
(500, 501, 1, 1, 1, 1);



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;