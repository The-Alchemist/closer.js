FROM node:20

# Set working directory
WORKDIR /app

# Add node_modules/.bin to PATH for accessing local binaries
ENV PATH="/app/node_modules/.bin:$PATH"

# Copy package files
COPY package.json ./


COPY Gruntfile.coffee ./
# Install dependencies
RUN npm install

# Copy source code
COPY src/ ./src/
COPY spec/ ./spec/

# Build the project (CoffeeScript will now be available)
RUN grunt build

# Expose port (not strictly necessary for REPL but good practice)
EXPOSE 3000

# Start the REPL
ENTRYPOINT ["node", "lib/src/start-repl.js"]
