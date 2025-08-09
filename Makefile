# Makefile

# Справка по доступным командам
help:
	@echo "Доступные команды:"
	@echo "  make init      - Инициализация проекта (создание .env, если его нет)"
	@echo "  make up        - Запуск всех контейнеров"
	@echo "  make down      - Остановка всех контейнеров"
	@echo "  make restart   - Перезапуск всех контейнеров"
	@echo "  make logs      - Просмотр логов"
	@echo "  make test      - Запуск тестов"
	@echo "  make cleanup   - Очистка неиспользуемых данных Docker"
	# @echo "  make restart_hard   - Перезапуск всех контейнеров с удалением томов (Осторожно!)"
	@echo "  make delete <имя контейнера>  - Удаление контейнера с образом и связанными томами"
	@echo "  make up-container <имя контейнера> - Создание и запуск определенного контейнера"
	@echo "  make update-container <имя контейнера> - Перезапускаем контейнер с обновлениями"

# Переменные окружения
ENV_FILE=.env
ENV_EXAMPLE_FILE=.env.example

# Команда для инициализации проекта
init:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Файл $(ENV_FILE) не найден. Копирую из $(ENV_EXAMPLE_FILE)..."; \
		cp $(ENV_EXAMPLE_FILE) $(ENV_FILE); \
		if [ -f $(ENV_FILE) ]; then \
			echo "Файл $(ENV_FILE) создан. Отредактируйте его перед запуском проекта!"; \
		fi; \
	else \
		echo "Файл $(ENV_FILE) уже существует. Пропускаю шаг создания."; \
	fi

# Запуск всех контейнеров
up:
	docker compose config --quiet
	docker compose up --build || echo "Ошибка запуска. Проверьте docker-compose.yml!"

# Остановка всех контейнеров
down:
	docker compose down

# Перезапуск всех контейнеров
restart: down up

# Перезапуск с удалением томов (осторожно!)
restart_hard:
	docker compose down -v
	docker compose up --build || echo "Ошибка запуска. Проверьте docker-compose.yml!"

# Просмотр логов
logs:
	docker compose logs -f

# Запуск тестов
test:
	pytest --cov=app tests/

# Очистка неиспользуемых данных Docker
cleanup:
	docker system prune -f
	docker volume prune -f
	docker network prune -f

.PHONY: delete
delete:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "Ошибка: Не указано имя контейнера. Использование: make delete <имя_контейнера>"; \
		exit 1; \
	fi; \
	CONTAINER=$(filter-out $@,$(MAKECMDGOALS)); \
	echo "Останавливаем и удаляем контейнер $$CONTAINER..."; \
	if docker ps -a --format '{{.Names}}' | grep -w $$CONTAINER > /dev/null; then \
		docker rm -f $$CONTAINER; \
	else \
		echo "Контейнер $$CONTAINER не найден."; \
	fi; \
	echo "Удаляем связанные тома..."; \
	if docker volume ls --format '{{.Name}}' | grep -w $$CONTAINER > /dev/null; then \
		docker volume rm $$(docker volume ls --filter name=$$CONTAINER --format '{{.Name}}') || true; \
	else \
		echo "Нет связанных томов для контейнера $$CONTAINER."; \
	fi; \
	echo "Удаляем связанный образ..."; \
	IMAGE=$$(docker inspect --format='{{.Image}}' $$CONTAINER 2>/dev/null); \
	if [ -n "$$IMAGE" ]; then \
		docker rmi $$IMAGE || true; \
	else \
		echo "Нет связанного образа для контейнера $$CONTAINER."; \
	fi; \
	echo "Удаляем все оставшиеся неиспользуемые тома..."; \
	docker volume prune -f

.PHONY: up-container
up-container:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "Ошибка: Не указано имя контейнера. Использование: make up-container <имя_сервиса>"; \
		exit 1; \
	fi; \
	SERVICE=$(filter-out $@,$(MAKECMDGOALS)); \
	echo "Проверяем конфиг..."; \
	docker compose config >/dev/null || exit 1; \
	echo "Собираем контейнер $$SERVICE..."; \
	docker compose build $$SERVICE; \
	if [ -n "$$(docker ps -q -f name=$$SERVICE)" ]; then \
		echo "Контейнер $$SERVICE уже запущен."; \
	else \
		echo "Запускаем контейнер $$SERVICE..."; \
		docker compose up -d $$SERVICE; \
	fi


.PHONY: update-container
update-container:
	@if [ -z "$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		echo "Ошибка: Не указано имя контейнера. Использование: make update-container <имя_сервиса>"; \
		exit 1; \
	fi; \
	SERVICE=$(filter-out $@,$(MAKECMDGOALS)); \
	docker compose config --quiet || exit 1; \
	echo "Останавливаем и удаляем контейнер $$SERVICE..."; \
	docker compose rm -fs $$SERVICE; \
	echo "Пересобираем образ для $$SERVICE..."; \
	docker compose build $$SERVICE; \
	echo "Запускаем контейнер $$SERVICE..."; \
	docker compose up -d $$SERVICE

%:
	@:
