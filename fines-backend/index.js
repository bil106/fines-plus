const express = require('express');
const app = express();
const port = 3000; // порт сервера

// чтобы принимать JSON-запросы
app.use(express.json());

// тестовый маршрут
app.get('/', (req, res) => {
  res.send('🚀 Backend работает!');
});

// пример API (например, проверка штрафов)
app.post('/api/fines', (req, res) => {
  const { carNumber, docSeries, docNumber } = req.body;
  console.log('📩 Запрос получен:', req.body);

  // пока просто отправим фейковый ответ
  res.json({
    success: true,
    fines: [
      { id: 1, carNumber, amount: 500, status: "unpaid" },
      { id: 2, carNumber, amount: 300, status: "paid" }
    ]
  });
});

app.listen(port, () => {
  console.log(`✅ Сервер запущен: http://localhost:${port}`);
});

