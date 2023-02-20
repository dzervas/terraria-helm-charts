#  The MIT License (MIT)
#
#  Copyright (c) Dimitris Zervas <https://dzervas.gr>
#  Copyright (c) Seppe Volkaerts <https://seppevolkaerts.be>
#  Copyright (c) 2015 Ryan Sheehan
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

FROM mono:6-slim
LABEL maintainer="Seppe Volkaerts <contact@seppevolkaerts.be>"

ENV PUID=1000
ENV PGID=1000

# The servers relies heavily on the user's home directory
RUN groupadd -g ${PGID} terraria && useradd -u ${PUID} -g ${PGID} -s /bin/false -m terraria && \
  mkdir -p /data/worlds /data/logs /data/config && \
  chown -R ${PUID}:${PGID} ${HOME} /data

WORKDIR /data

RUN apt-get update -y && \
  apt-get install -y pcregrep unzip wget && \
  rm -rf /var/lib/apt/lists* /tmp/*

COPY entrypoint.sh /entrypoint.sh

ARG VERSION=1.4.4.9
RUN wget https://terraria.org/api/download/pc-dedicated-server/terraria-server-$(echo $VERSION | tr -d '.').zip -O /server.zip

RUN unzip /server -d /terraria && \
  mkdir /terraria-server && \
  mv /terraria/$(echo $VERSION | tr -d '.')/Linux/* /terraria-server && \
  rm -rf /server.zip /terraria

# Fix the 'Your mono runtime and class libraries are out of sync.' error
# RUN rm /terraria-server/System* /terraria-server/Mono* /terraria-server/monoconfig /terraria-server/mscorlib.dll
RUN rm /terraria-server/System.dll

USER ${PUID}:${PGID}

VOLUME [ "/data/worlds", "/data/logs", "/data/config" ]
EXPOSE 7777/tcp
ENTRYPOINT [ "/entrypoint.sh" ]
