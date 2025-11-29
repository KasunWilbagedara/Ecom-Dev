# Use Node 20
FROM node:20

# Create app directory
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the backend code
COPY . .

# Expose port 5000
EXPOSE 5000

# Start the backend server
CMD ["npm", "start"]
